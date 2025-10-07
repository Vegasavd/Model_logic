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

-- Tabla: facturacion (datos de facturas electrónicas / documentos fiscales)
CREATE TABLE facturacion (
    id_factura SERIAL PRIMARY KEY,
    id_venta INTEGER NOT NULL REFERENCES venta(id_venta) ON DELETE CASCADE,
    serie VARCHAR(20),
    folio VARCHAR(50),
    fecha_emision TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    total NUMERIC(14,2) NOT NULL,
    metodo_pago VARCHAR(50),
    estado VARCHAR(30) DEFAULT 'emitida',
    xml_path TEXT, -- ruta o blob externo
    pdf_path TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now()
);

CREATE INDEX idx_facturacion_venta ON facturacion(id_venta);

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

-- -----------------------------------------------------------------
-- Tablas y triggers para compras a proveedores
-- Diseñado para: crear encabezado de compra, líneas de compra, recalcular
-- total de la compra y aplicar la recepción de las líneas al inventario
-- Reglas asumidas (puedes cambiar si prefieres otra política):
-- 1) Las compras se crean en estado 'pendiente'. Cuando se marca
--    'recibida' = TRUE (o estado = 'recibida') se incrementa el inventario
--    en la tienda receptora (id_tienda en compra) sumando las cantidades.
-- 2) La aplicación a inventario ocurre una única vez en la transición
--    recibida: FALSE -> TRUE. No se revierte automáticamente si se cambia a FALSE.
-- 3) Si una línea se inserta/actualiza y la compra ya está marcada como
--    recibida, la línea se aplica inmediatamente al inventario.
-- -----------------------------------------------------------------

-- Tabla: compra (encabezado)
CREATE TABLE compra (
    id_compra SERIAL PRIMARY KEY,
    fecha_compra TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    id_proveedor INTEGER REFERENCES proveedores(id_proveedor) ON DELETE SET NULL,
    id_tienda INTEGER REFERENCES tiendas(id_tienda) ON DELETE SET NULL, -- tienda que recibe
    total_compra NUMERIC(14,2) DEFAULT 0,
    estado VARCHAR(30) DEFAULT 'pendiente', -- 'pendiente','recibida','cancelada'
    recibida BOOLEAN DEFAULT FALSE,
    aplicada BOOLEAN DEFAULT FALSE, -- indica si la compra ya fue aplicada al inventario
    fecha_recepcion TIMESTAMP WITHOUT TIME ZONE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now()
);

CREATE INDEX idx_compra_proveedor ON compra(id_proveedor);
CREATE INDEX idx_compra_tienda ON compra(id_tienda);

-- Tabla: compra_producto (líneas de compra)
CREATE TABLE compra_producto (
    id_compra_producto SERIAL PRIMARY KEY,
    id_compra INTEGER NOT NULL REFERENCES compra(id_compra) ON DELETE CASCADE,
    id_producto INTEGER NOT NULL REFERENCES productos(id_producto) ON DELETE RESTRICT,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(12,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal NUMERIC(14,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now()
);

CREATE INDEX idx_compra_producto_compra ON compra_producto(id_compra);
CREATE INDEX idx_compra_producto_producto ON compra_producto(id_producto);

-- Trigger para recalcular compra.total_compra cuando cambien líneas
CREATE OR REPLACE FUNCTION trg_recalc_compra_total()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        UPDATE compra
            SET total_compra = COALESCE((SELECT SUM(subtotal) FROM compra_producto WHERE id_compra = OLD.id_compra), 0),
                updated_at = now()
            WHERE id_compra = OLD.id_compra;
        RETURN OLD;
    ELSE
        UPDATE compra
            SET total_compra = COALESCE((SELECT SUM(subtotal) FROM compra_producto WHERE id_compra = NEW.id_compra), 0),
                updated_at = now()
            WHERE id_compra = NEW.id_compra;
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_compra_producto_after_ins_upd
    AFTER INSERT OR UPDATE ON compra_producto
    FOR EACH ROW EXECUTE FUNCTION trg_recalc_compra_total();

CREATE TRIGGER trg_compra_producto_after_del
    AFTER DELETE ON compra_producto
    FOR EACH ROW EXECUTE FUNCTION trg_recalc_compra_total();

-- Function: aplicar líneas de compra al inventario cuando la compra está recibida
CREATE OR REPLACE FUNCTION trg_apply_compra_producto_to_inventario()
RETURNS TRIGGER AS $$
DECLARE
    v_id_tienda INTEGER;
    v_aplicada BOOLEAN;
BEGIN
    -- obtener la tienda receptora y el flag aplicada desde la tabla compra
    SELECT id_tienda, aplicada INTO v_id_tienda, v_aplicada FROM compra WHERE id_compra = NEW.id_compra;

    -- si no hay tienda definida o ya aplicada, no aplicamos inventario
    IF v_id_tienda IS NULL OR v_aplicada THEN
        RETURN NEW;
    END IF;

    -- solo aplicar si la compra está marcada como recibida
    IF (SELECT recibida FROM compra WHERE id_compra = NEW.id_compra) THEN
        -- insertar o actualizar inventario (upsert)
        INSERT INTO inventario (id_tienda, id_producto, cantidad, fecha_ultima_actualizacion, updated_at)
        VALUES (v_id_tienda, NEW.id_producto, NEW.cantidad, now(), now())
        ON CONFLICT (id_tienda, id_producto)
        DO UPDATE SET cantidad = inventario.cantidad + EXCLUDED.cantidad,
        fecha_ultima_actualizacion = now(),
        updated_at = now();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_compra_producto_after_ins_upd_inventory
    AFTER INSERT OR UPDATE ON compra_producto
    FOR EACH ROW EXECUTE FUNCTION trg_apply_compra_producto_to_inventario();

-- Cuando una compra cambia su flag `recibida` de FALSE -> TRUE, aplicar todas sus líneas
CREATE OR REPLACE FUNCTION trg_compra_after_update_recibida()
RETURNS TRIGGER AS $$
DECLARE
    rec RECORD;
    v_id_tienda INTEGER := NEW.id_tienda;
    v_aplicada BOOLEAN := NEW.aplicada;
BEGIN
    -- si la bandera recibida cambia de false a true y no ha sido aplicada
    IF (OLD.recibida IS DISTINCT FROM NEW.recibida) AND (NEW.recibida = TRUE) AND (v_aplicada = FALSE OR v_aplicada IS NULL) THEN
        IF v_id_tienda IS NULL THEN
            RETURN NEW; -- sin tienda, no aplicamos
        END IF;

        FOR rec IN SELECT * FROM compra_producto WHERE id_compra = NEW.id_compra LOOP
            INSERT INTO inventario (id_tienda, id_producto, cantidad, fecha_ultima_actualizacion, updated_at)
            VALUES (v_id_tienda, rec.id_producto, rec.cantidad, now(), now())
            ON CONFLICT (id_tienda, id_producto)
            DO UPDATE SET cantidad = inventario.cantidad + EXCLUDED.cantidad,
            fecha_ultima_actualizacion = now(),
            updated_at = now();
        END LOOP;

        -- marcar fecha_recepcion si no se proporcionó
        IF NEW.fecha_recepcion IS NULL THEN
            UPDATE compra SET fecha_recepcion = now() WHERE id_compra = NEW.id_compra;
        END IF;

        -- marcar como aplicada para evitar re-aplicaciones
        UPDATE compra SET aplicada = TRUE WHERE id_compra = NEW.id_compra;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_compra_after_update_recibida
    AFTER UPDATE ON compra
    FOR EACH ROW EXECUTE FUNCTION trg_compra_after_update_recibida();

-- Triggers para mantener updated_at en compra y compra_producto
CREATE TRIGGER trg_compra_updated_at
    BEFORE UPDATE ON compra FOR EACH ROW
    EXECUTE FUNCTION trg_set_updated_at();

CREATE TRIGGER trg_compra_producto_updated_at
    BEFORE UPDATE ON compra_producto FOR EACH ROW
    EXECUTE FUNCTION trg_set_updated_at();

-- Nota: Esta implementación aplica incrementos al inventario en la recepción.
-- Si prefieres separar recepción en un documento distinto o mantener movimientos
-- históricos (entradas/salidas) es recomendable crear una tabla `movimiento_inventario`
-- y registrar una fila por cada cambio, dejando el agregado a `inventario` como
-- proyección/estado. También considerar idempotencia (marcar que la compra ya fue
-- aplicada) si el proceso puede ejecutarse de nuevo.

-- Fin del archivo
