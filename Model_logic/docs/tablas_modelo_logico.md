# Tablas del Modelo Lógico — Sistema de Ventas

Este documento describe las tablas del modelo lógico implementado en `sql/modelo_logico.sql`.
Cada sección contiene una tabla con las columnas: Campo | Tipo | PK/FK | NULL | Default | Notas.

## Índice

- `tiendas`
- `puesto_empleados`
- `empleados`
- `proveedores`
- `categoria_productos`
- `productos`
- `inventario`
- `clientes`
- `venta`
- `detalles_venta`
- `facturacion`
- `compra`
- `compra_producto`
- Triggers y funciones importantes

---

## tiendas

| Campo | Tipo | PK / FK | NULL | Default | Notas |
|---|---|---:|:---:|:---:|---|
| id_tienda | SERIAL / INTEGER | PK | NO | nextval() | Identificador de la tienda |
| nombre | VARCHAR(200) |  | NO |  | Nombre comercial |
| direccion | VARCHAR(300) |  | SI |  | Dirección física |
| telefono | VARCHAR(50) |  | SI |  | Teléfono de contacto |
| ciudad | VARCHAR(100) |  | SI |  | Ciudad/Localidad |
| created_at | TIMESTAMP |  | NO | now() | Fecha de creación |
| updated_at | TIMESTAMP |  | NO | now() | Fecha de última modificación (trigger) |

---

## puesto_empleados

| Campo | Tipo | PK / FK | NULL | Default | Notas |
|---|---|---:|:---:|:---:|---|
| id_puesto | SERIAL / INTEGER | PK | NO | nextval() | Identificador del puesto |
| nombre_puesto | VARCHAR(150) |  | NO |  | Ej: Vendedor, Cajero, Gerente |
| created_at | TIMESTAMP |  | NO | now() | |
| updated_at | TIMESTAMP |  | NO | now() | |

---

## empleados

| Campo | Tipo | PK / FK | NULL | Default | Notas |
|---|---|---:|:---:|:---:|---|
| id_empleado | SERIAL / INTEGER | PK | NO | nextval() | |
| nombre | VARCHAR(200) |  | NO |  | Nombre propio |
| apellido_paterno | VARCHAR(150) |  | SI |  | |
| apellido_materno | VARCHAR(150) |  | SI |  | |
| rfc | VARCHAR(20) |  | SI |  | Identificador fiscal opcional |
| fecha_contratacion | DATE |  | NO |  | Fecha de inicio |
| id_tienda | INTEGER | FK -> tiendas(id_tienda) | SI |  | ON DELETE SET NULL |
| id_puesto | INTEGER | FK -> puesto_empleados(id_puesto) | SI |  | ON DELETE SET NULL |
| created_at | TIMESTAMP |  | NO | now() | |
| updated_at | TIMESTAMP |  | NO | now() | |

---

## proveedores

| Campo | Tipo | PK / FK | NULL | Default | Notas |
|---|---|---:|:---:|:---:|---|
| id_proveedor | SERIAL / INTEGER | PK | NO | nextval() | |
| nombre_empresa | VARCHAR(200) |  | NO |  | Razón social |
| contacto_nombre | VARCHAR(200) |  | SI |  | Persona de contacto |
| contacto_email | VARCHAR(150) |  | SI |  | |
| contacto_telefono | VARCHAR(50) |  | SI |  | |
| created_at | TIMESTAMP |  | NO | now() | |
| updated_at | TIMESTAMP |  | NO | now() | |

---

## categoria_productos

| Campo | Tipo | PK / FK | NULL | Default | Notas |
|---|---|---:|:---:|:---:|---|
| id_categoria | SERIAL / INTEGER | PK | NO | nextval() | |
| nombre_categoria | VARCHAR(150) |  | NO |  | Nombre de la categoría |
| descripcion | TEXT |  | SI |  | Descripción libre |
| created_at | TIMESTAMP |  | NO | now() | |
| updated_at | TIMESTAMP |  | NO | now() | |

---

## productos

| Campo | Tipo | PK / FK | NULL | Default | Notas |
|---|---|---:|:---:|:---:|---|
| id_producto | SERIAL / INTEGER | PK | NO | nextval() | |
| sku | VARCHAR(80) |  | NO |  | Único (INDEX / UNIQUE) |
| nombre_producto | VARCHAR(250) |  | NO |  | |
| descripcion | TEXT |  | SI |  | |
| precio_venta | NUMERIC(12,2) |  | SI |  | Precio de venta sugerido |
| costo_compra | NUMERIC(12,2) |  | SI |  | Costo del proveedor |
| id_categoria | INTEGER | FK -> categoria_productos(id_categoria) | SI |  | ON DELETE SET NULL |
| id_proveedor | INTEGER | FK -> proveedores(id_proveedor) | SI |  | ON DELETE SET NULL |
| created_at | TIMESTAMP |  | NO | now() | |
| updated_at | TIMESTAMP |  | NO | now() | |

---

## inventario

| Campo | Tipo | PK / FK | NULL | Default | Notas |
|---|---|---:|:---:|:---:|---|
| id_tienda | INTEGER | PK (compuesto) / FK -> tiendas(id_tienda) | NO |  | Parte de PK compuesta |
| id_producto | INTEGER | PK (compuesto) / FK -> productos(id_producto) | NO |  | Parte de PK compuesta |
| cantidad | INTEGER |  | NO | 0 | Cantidad disponible en la tienda |
| fecha_ultima_actualizacion | TIMESTAMP |  | NO | now() | Última modificación de stock |
| updated_at | TIMESTAMP |  | NO | now() | Mantener con trigger |

Índices recomendados: índice por `id_producto` para consultas globales.

---

## clientes

| Campo | Tipo | PK / FK | NULL | Default | Notas |
|---|---|---:|:---:|:---:|---|
| id_cliente | SERIAL / INTEGER | PK | NO | nextval() | |
| nombre | VARCHAR(250) |  | NO |  | Nombre completo |
| rfc | VARCHAR(13) |  | SI |  | UNIQUE parcial (WHERE rfc IS NOT NULL) |
| email | VARCHAR(150) |  | SI |  | |
| telefono | VARCHAR(50) |  | SI |  | |
| created_at | TIMESTAMP |  | NO | now() | |
| updated_at | TIMESTAMP |  | NO | now() | |

---

## venta

| Campo | Tipo | PK / FK | NULL | Default | Notas |
|---|---|---:|:---:|:---:|---|
| id_venta | SERIAL / INTEGER | PK | NO | nextval() | |
| fecha_hora | TIMESTAMP |  | NO | now() | Momento de la venta |
| monto_total | NUMERIC(14,2) |  | NO | 0 | Mantener por trigger (SUM de subtotales) |
| id_cliente | INTEGER | FK -> clientes(id_cliente) | SI |  | ON DELETE SET NULL |
| id_empleado | INTEGER | FK -> empleados(id_empleado) | SI |  | ON DELETE SET NULL |
| id_tienda | INTEGER | FK -> tiendas(id_tienda) | SI |  | ON DELETE SET NULL |
| created_at | TIMESTAMP |  | NO | now() | |
| updated_at | TIMESTAMP |  | NO | now() | |

Índices: `id_cliente`, `id_empleado`, `id_tienda`.

---

## detalles_venta

| Campo | Tipo | PK / FK | NULL | Default | Notas |
|---|---|---:|:---:|:---:|---|
| id_detalle_venta | SERIAL / INTEGER | PK | NO | nextval() | |
| id_venta | INTEGER | FK -> venta(id_venta) | NO |  | ON DELETE CASCADE |
| id_producto | INTEGER | FK -> productos(id_producto) | NO |  | ON DELETE RESTRICT |
| cantidad | INTEGER |  | NO |  | CHECK (cantidad > 0) |
| precio_unitario | NUMERIC(12,2) |  | NO |  | CHECK (>= 0) |
| subtotal | NUMERIC(14,2) |  | NO | GENERATED AS (cantidad * precio_unitario) STORED | Calculado en columna |
| created_at | TIMESTAMP |  | NO | now() | |
| updated_at | TIMESTAMP |  | NO | now() | |

Índice: `id_venta` para acceso por cabecera.

---

## facturacion

| Campo | Tipo | PK / FK | NULL | Default | Notas |
|---|---|---:|:---:|:---:|---|
| id_factura | SERIAL / INTEGER | PK | NO | nextval() | |
| id_venta | INTEGER | FK -> venta(id_venta) | NO |  | ON DELETE CASCADE |
| serie | VARCHAR(20) |  | SI |  | Serie del CFDI |
| folio | VARCHAR(50) |  | SI |  | Folio o folios externos |
| fecha_emision | TIMESTAMP |  | NO | now() | |
| total | NUMERIC(14,2) |  | NO | 0 | Total facturado |
| metodo_pago | VARCHAR(50) |  | SI |  | |
| estado | VARCHAR(30) |  | NO | 'emitida' | Estado del proceso |
| xml_path | TEXT |  | SI |  | Ruta al XML si se guarda fuera de BD |
| pdf_path | TEXT |  | SI |  | Ruta al PDF exportado |
| created_at | TIMESTAMP |  | NO | now() | |
| updated_at | TIMESTAMP |  | NO | now() | |

---

## compra

| Campo | Tipo | PK / FK | NULL | Default | Notas |
|---|---|---:|:---:|:---:|---|
| id_compra | SERIAL / INTEGER | PK | NO | nextval() | |
| fecha_compra | TIMESTAMP |  | NO | now() | |
| id_proveedor | INTEGER | FK -> proveedores(id_proveedor) | SI |  | ON DELETE SET NULL |
| id_tienda | INTEGER | FK -> tiendas(id_tienda) | SI |  | Tienda receptora |
| total_compra | NUMERIC(14,2) |  | NO | 0 | Mantenido por trigger |
| estado | VARCHAR(30) |  | NO | 'pendiente' | Ej: pendiente, cancelada, recibida |
| recibida | BOOLEAN |  | NO | FALSE | Marca recepción física |
| aplicada | BOOLEAN |  | NO | FALSE | Evita re-aplicar stock |
| fecha_recepcion | TIMESTAMP |  | SI |  | Fecha cuando se recibe físicamente |
| created_at | TIMESTAMP |  | NO | now() | |
| updated_at | TIMESTAMP |  | NO | now() | |

Índices: `id_proveedor`, `id_tienda`.

---

## compra_producto

| Campo | Tipo | PK / FK | NULL | Default | Notas |
|---|---|---:|:---:|:---:|---|
| id_compra_producto | SERIAL / INTEGER | PK | NO | nextval() | |
| id_compra | INTEGER | FK -> compra(id_compra) | NO |  | ON DELETE CASCADE |
| id_producto | INTEGER | FK -> productos(id_producto) | NO |  | ON DELETE RESTRICT |
| cantidad | INTEGER |  | NO |  | CHECK (cantidad > 0) |
| precio_unitario | NUMERIC(12,2) |  | NO |  | CHECK (>= 0) |
| subtotal | NUMERIC(14,2) |  | NO | GENERATED AS (cantidad * precio_unitario) STORED | |
| created_at | TIMESTAMP |  | NO | now() | |
| updated_at | TIMESTAMP |  | NO | now() | |

Índices: `id_compra`, `id_producto`.

---

## Triggers y funciones importantes

- `trg_set_updated_at()` — BEFORE UPDATE: mantiene `updated_at = now()`.
- `trg_recalc_venta_monto()` — AFTER INSERT/UPDATE/DELETE en `detalles_venta`: recalcula `venta.monto_total` (SUM de `subtotal`).
- `trg_recalc_compra_total()` — AFTER INSERT/UPDATE/DELETE en `compra_producto`: recalcula `compra.total_compra`.
- `trg_apply_compra_producto_to_inventario()` — Aplica líneas de compra al `inventario` (INSERT ... ON CONFLICT DO UPDATE) cuando la compra está marcada `recibida`.
- `trg_compra_after_update_recibida()` — Detecta la transición `recibida: FALSE -> TRUE`, aplica todas las líneas al inventario, marca `aplicada = TRUE` y registra `fecha_recepcion`.

---

## Ejemplos rápidos

Insertar venta con líneas (forma recomendada):

```sql
BEGIN;
INSERT INTO venta (id_cliente, id_empleado, id_tienda)
VALUES (1, 1, 1)
RETURNING id_venta;

-- Usar el id retornado para insertar detalles_venta
INSERT INTO detalles_venta (id_venta, id_producto, cantidad, precio_unitario)
VALUES (<<id_venta>>, 10, 2, 199.99), (<<id_venta>>, 11, 1, 99.99);
COMMIT;
```

Insertar compra y marcar recibida (aplica stock al actualizar `recibida`):

```sql
BEGIN;
INSERT INTO compra (id_proveedor, id_tienda) VALUES (1, 1) RETURNING id_compra;
INSERT INTO compra_producto (id_compra, id_producto, cantidad, precio_unitario)
VALUES (<<id_compra>>, 10, 50, 90.00), (<<id_compra>>, 11, 30, 85.00);
COMMIT;

-- Luego marcar como recibida para disparar trigger de aplicación a inventario
UPDATE compra SET recibida = TRUE WHERE id_compra = <<id_compra>>;
```

---

## Recomendaciones

- Para PostgreSQL < 12: convertir las columnas `GENERATED` (subtotal) a triggers o calcular en la carga.
- Añadir `movimiento_inventario` si necesitas trazabilidad por entradas/salidas (audit trail).
- Para cargas masivas (CSV) usa `\copy` desde cliente o tablas staging para performance.

---


- Generar una versión PDF (requiere `pandoc`) y dejarla en `out/`.
- Exportar a HTML para previsualización rápida en navegador.
- Extraer automáticamente las columnas desde `sql/modelo_logico.sql` para mantener este documento sincronizado.


