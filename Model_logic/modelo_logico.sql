-- Modelo lógico: Sistema de ventas (esquema según imágenes provistas)
-- Entidades: tiendas, puesto_empleados, empleados, proveedores, categoria_productos,
-- productos, inventario, clientes, venta, detalles_venta

-- Tabla: tiendas
CREATE TABLE tiendas (
    id_tienda SERIAL PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    direccion VARCHAR(300),
    telefono VARCHAR(50),
    ciudad VARCHAR(100)
);

-- auditoría
ALTER TABLE tiendas
    ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now();

-- Tabla: puesto_empleados
CREATE TABLE puesto_empleados (
    id_puesto SERIAL PRIMARY KEY,
    nombre_puesto VARCHAR(150) NOT NULL
);

ALTER TABLE puesto_empleados
    ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now();

-- Tabla: empleados
CREATE TABLE empleados (
    id_empleado SERIAL PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    apellido_paterno VARCHAR(150),
    apellido_materno VARCHAR(150),
    rfc VARCHAR(20),
    fecha_contratacion DATE NOT NULL,
    id_tienda INTEGER REFERENCES tiendas(id_tienda) ON DELETE SET NULL,
    id_puesto INTEGER REFERENCES puesto_empleados(id_puesto) ON DELETE SET NULL
);

ALTER TABLE empleados
    ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now();

-- índices para consultas frecuentes por tienda/puesto
CREATE INDEX idx_empleados_tienda ON empleados(id_tienda);
CREATE INDEX idx_empleados_puesto ON empleados(id_puesto);

-- Tabla: proveedores
CREATE TABLE proveedores (
    id_proveedor SERIAL PRIMARY KEY,
    nombre_empresa VARCHAR(200) NOT NULL,
    contacto_nombre VARCHAR(200),
    contacto_email VARCHAR(150),
    contacto_telefono VARCHAR(50)
);

ALTER TABLE proveedores
    ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now();

-- Tabla: categoria_productos
CREATE TABLE categoria_productos (
    id_categoria SERIAL PRIMARY KEY,
    nombre_categoria VARCHAR(150) NOT NULL,
    descripcion TEXT
);

ALTER TABLE categoria_productos
    ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now();

-- Tabla: productos
CREATE TABLE productos (
    id_producto SERIAL PRIMARY KEY,
    sku VARCHAR(80) NOT NULL UNIQUE,
    nombre_producto VARCHAR(250) NOT NULL,
    descripcion TEXT,
    precio_venta NUMERIC(12,2),
    costo_compra NUMERIC(12,2),
    id_categoria INTEGER REFERENCES categoria_productos(id_categoria) ON DELETE SET NULL,
    id_proveedor INTEGER REFERENCES proveedores(id_proveedor) ON DELETE SET NULL
);

CREATE INDEX idx_productos_sku ON productos(sku);
CREATE INDEX idx_productos_categoria ON productos(id_categoria);
CREATE INDEX idx_productos_proveedor ON productos(id_proveedor);

ALTER TABLE productos
    ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now();

-- Tabla: inventario (PK compuesta: id_tienda + id_producto)
CREATE TABLE inventario (
    id_tienda INTEGER NOT NULL REFERENCES tiendas(id_tienda) ON DELETE CASCADE,
    id_producto INTEGER NOT NULL REFERENCES productos(id_producto) ON DELETE CASCADE,
    cantidad INTEGER NOT NULL DEFAULT 0,
    fecha_ultima_actualizacion TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    PRIMARY KEY (id_tienda, id_producto)
);

-- índice compuesto ya existe por PK; añadir índice por producto para consultas globales
CREATE INDEX idx_inventario_producto ON inventario(id_producto);


-- Tabla: clientes
CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(250) NOT NULL,
    rfc VARCHAR(13),
    email VARCHAR(150),
    telefono VARCHAR(50)
);

ALTER TABLE clientes
    ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now();

-- RFC único cuando no sea NULL
CREATE UNIQUE INDEX ux_clientes_rfc ON clientes(rfc) WHERE rfc IS NOT NULL;

-- Tabla: venta (encabezado)
CREATE TABLE venta (
    id_venta SERIAL PRIMARY KEY,
    fecha_hora TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    monto_total NUMERIC(14,2) DEFAULT 0,
    id_cliente INTEGER REFERENCES clientes(id_cliente) ON DELETE SET NULL,
    id_empleado INTEGER REFERENCES empleados(id_empleado) ON DELETE SET NULL,
    id_tienda INTEGER REFERENCES tiendas(id_tienda) ON DELETE SET NULL
);

ALTER TABLE venta
    ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now();

CREATE INDEX idx_venta_cliente ON venta(id_cliente);
CREATE INDEX idx_venta_empleado ON venta(id_empleado);
CREATE INDEX idx_venta_tienda ON venta(id_tienda);

-- Tabla: detalles_venta (líneas)
CREATE TABLE detalles_venta (
    id_detalle_venta SERIAL PRIMARY KEY,
    id_venta INTEGER NOT NULL REFERENCES venta(id_venta) ON DELETE CASCADE,
    id_producto INTEGER NOT NULL REFERENCES productos(id_producto) ON DELETE RESTRICT,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(12,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal NUMERIC(14,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED
);

CREATE INDEX idx_detalles_venta_venta ON detalles_venta(id_venta);

ALTER TABLE detalles_venta
    ADD COLUMN created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now();

-- Trigger genérico para mantener `updated_at`
CREATE OR REPLACE FUNCTION trg_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Añadir columna updated_at en tablas si no existe y crear triggers
-- lista de tablas que tendrán trigger: tiendas, puesto_empleados, empleados, proveedores,
-- categoria_productos, productos, inventario, clientes, venta

-- Añadir updated_at a inventario y detalles_venta (si no existe ya)
ALTER TABLE inventario
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now();

ALTER TABLE detalles_venta
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now();

-- Crear triggers para las tablas (actualizan updated_at en UPDATE)
CREATE TRIGGER trg_tiendas_updated_at
    BEFORE UPDATE ON tiendas FOR EACH ROW
    EXECUTE FUNCTION trg_set_updated_at();

CREATE TRIGGER trg_puesto_empleados_updated_at
    BEFORE UPDATE ON puesto_empleados FOR EACH ROW
    EXECUTE FUNCTION trg_set_updated_at();

CREATE TRIGGER trg_empleados_updated_at
    BEFORE UPDATE ON empleados FOR EACH ROW
    EXECUTE FUNCTION trg_set_updated_at();

CREATE TRIGGER trg_proveedores_updated_at
    BEFORE UPDATE ON proveedores FOR EACH ROW
    EXECUTE FUNCTION trg_set_updated_at();

CREATE TRIGGER trg_categoria_productos_updated_at
    BEFORE UPDATE ON categoria_productos FOR EACH ROW
    EXECUTE FUNCTION trg_set_updated_at();

CREATE TRIGGER trg_productos_updated_at
    BEFORE UPDATE ON productos FOR EACH ROW
    EXECUTE FUNCTION trg_set_updated_at();

CREATE TRIGGER trg_inventario_updated_at
    BEFORE UPDATE ON inventario FOR EACH ROW
    EXECUTE FUNCTION trg_set_updated_at();

CREATE TRIGGER trg_clientes_updated_at
    BEFORE UPDATE ON clientes FOR EACH ROW
    EXECUTE FUNCTION trg_set_updated_at();

CREATE TRIGGER trg_venta_updated_at
    BEFORE UPDATE ON venta FOR EACH ROW
    EXECUTE FUNCTION trg_set_updated_at();

CREATE TRIGGER trg_detalles_venta_updated_at
    BEFORE UPDATE ON detalles_venta FOR EACH ROW
    EXECUTE FUNCTION trg_set_updated_at();

-- Trigger para recalcular venta.monto_total cuando cambien detalles_venta
CREATE OR REPLACE FUNCTION trg_recalc_venta_monto()
RETURNS TRIGGER AS $$
BEGIN
    -- Después de INSERT/UPDATE/DELETE en detalles_venta, recalcular el total de la venta afectada
    IF (TG_OP = 'DELETE') THEN
        PERFORM 1; -- no-op para sintaxis, OLD.id_venta existe
        UPDATE venta
            SET monto_total = COALESCE((SELECT SUM(subtotal) FROM detalles_venta WHERE id_venta = OLD.id_venta), 0),
                    updated_at = now()
            WHERE id_venta = OLD.id_venta;
        RETURN OLD;
    ELSE
        UPDATE venta
            SET monto_total = COALESCE((SELECT SUM(subtotal) FROM detalles_venta WHERE id_venta = NEW.id_venta), 0),
                    updated_at = now()
            WHERE id_venta = NEW.id_venta;
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_detalles_venta_after_ins_upd
    AFTER INSERT OR UPDATE ON detalles_venta
    FOR EACH ROW EXECUTE FUNCTION trg_recalc_venta_monto();

CREATE TRIGGER trg_detalles_venta_after_del
    AFTER DELETE ON detalles_venta
    FOR EACH ROW EXECUTE FUNCTION trg_recalc_venta_monto();

-- Nota: considerar triggers para actualizar `venta.monto_total` al insertar/actualizar/eliminar líneas.

-- Fin del archivo
