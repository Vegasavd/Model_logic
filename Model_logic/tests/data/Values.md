Coloca aquí los CSV que el generador crea y usa `psql` con `\copy` para cargarlos.

Generador: `tests/generate_csvs.py`

Ejemplo (Windows cmd):

python tests\generate_csvs.py --output tests\data --ventas 3000

En psql (cliente):
\copy tiendas(id_tienda,nombre,direccion,telefono,ciudad,created_at,updated_at) FROM 'tests/data/tiendas.csv' WITH CSV HEADER
\copy puesto_empleados(id_puesto,nombre_puesto,created_at,updated_at) FROM 'tests/data/puesto_empleados.csv' WITH CSV HEADER
\copy proveedores(id_proveedor,nombre_empresa,contacto_nombre,contacto_email,contacto_telefono,created_at,updated_at) FROM 'tests/data/proveedores.csv' WITH CSV HEADER
\copy categoria_productos(id_categoria,nombre_categoria,descripcion,created_at,updated_at) FROM 'tests/data/categoria_productos.csv' WITH CSV HEADER
\copy productos(id_producto,sku,nombre_producto,descripcion,precio_venta,costo_compra,id_categoria,id_proveedor,created_at,updated_at) FROM 'tests/data/productos.csv' WITH CSV HEADER
\copy clientes(id_cliente,nombre,rfc,email,telefono,created_at,updated_at) FROM 'tests/data/clientes.csv' WITH CSV HEADER
\copy empleados(id_empleado,nombre,apellido_paterno,apellido_materno,rfc,fecha_contratacion,id_tienda,id_puesto,created_at,updated_at) FROM 'tests/data/empleados.csv' WITH CSV HEADER
\copy inventario(id_tienda,id_producto,cantidad,fecha_ultima_actualizacion,updated_at) FROM 'tests/data/inventario.csv' WITH CSV HEADER
\copy venta(id_venta,fecha_hora,monto_total,id_cliente,id_empleado,id_tienda,created_at,updated_at) FROM 'tests/data/venta.csv' WITH CSV HEADER
\copy detalles_venta(id_detalle_venta,id_venta,id_producto,cantidad,precio_unitario,subtotal,created_at,updated_at) FROM 'tests/data/detalles_venta.csv' WITH CSV HEADER
\copy compra(id_compra,fecha_compra,id_proveedor,id_tienda,total_compra,estado,recibida,aplicada,fecha_recepcion,created_at,updated_at) FROM 'tests/data/compra.csv' WITH CSV HEADER
\copy compra_producto(id_compra_producto,id_compra,id_producto,cantidad,precio_unitario,subtotal,created_at,updated_at) FROM 'tests/data/compra_producto.csv' WITH CSV HEADER
\copy facturacion(id_factura,id_venta,serie,folio,fecha_emision,total,metodo_pago,estado,xml_path,pdf_path,created_at,updated_at) FROM 'tests/data/facturacion.csv' WITH CSV HEADER


Nota: Algunas columnas (e.g., subtotal) son GENERATED en la base y no deben incluirse en los CSVs de import si el servidor no soporta la inserción directa en columnas generadas; en nuestros CSVs generados incluimos `subtotal` para facilitar verificaciones, pero puedes omitirlas al importar y dejar que la base las calcule si prefieres.

---

# Values (orden y formato)

Este archivo documenta los "values" (orden/formatos) usados en los CSVs generados para facilitar la importación y la presentación.

Reglas generales de orden y formato en los CSVs generados:

- Todas las filas incluyen cabeceras con los nombres exactos de las columnas usadas en el DDL.
- Las columnas ID se generan secuencialmente para permitir `\copy` directo (ej: `id_venta` desde 1..3000).
- Fechas y timestamps usan formato `YYYY-MM-DD HH:MM:SS` (sin zona), por ejemplo `2025-10-09 14:23:11`.
- Campos numéricos (precio, subtotal, monto_total) usan punto decimal con dos decimales (ej. `199.99`).
- Los archivos están pensados para cargarse en el orden lógico que respeta las FK:
  1. tiendas.csv
  ```markdown
  Valores y orden para los CSV generados por `tests/generate_csvs.py`

  IMPORTANTE: el generador crea una subcarpeta por ejecución bajo la carpeta base (por defecto `tests/data/`),
  por ejemplo `tests/data/run_20251009_200252/`. Los ejemplos de `\copy` abajo asumen que estás usando esa
  carpeta de ejecución; reemplaza `RUN_DIR` por la ruta real.

  Generador: `tests/generate_csvs.py` (soporta `--out-dir` y la variable de entorno `CSV_OUT_DIR`).

  Ejemplo (Windows cmd) — generar CSVs en el directorio por defecto `tests/data/run_...`:

  ```bat
  python tests\generate_csvs.py
  ```

  Ejemplo (especificar carpeta base):

  ```bat
  python tests\generate_csvs.py --out-dir c:\ruta\a\mis\csvs
  ```

  Lista de CSVs generados (por ejecución, dentro de la carpeta `run_YYYYMMDD_HHMMSS`):

  - `tiendas.csv`
  - `puesto_empleados.csv`
  - `empleados.csv`
  - `proveedores.csv`
  - `categoria_productos.csv`
  - `productos.csv`
  - `clientes.csv`
  - `venta.csv`
  - `detalles_venta.csv`
  - `inventario.csv`
  - `facturacion.csv`
  - `compra.csv`
  - `compra_producto.csv`

  Ejemplo de uso en `psql` (reemplaza RUN_DIR por la carpeta creada por el generador):

  ```sql
  \copy tiendas(id_tienda,nombre,direccion,telefono,ciudad,created_at,updated_at) FROM 'RUN_DIR/tiendas.csv' WITH CSV HEADER;
  \copy puesto_empleados(id_puesto,nombre_puesto,created_at,updated_at) FROM 'RUN_DIR/puesto_empleados.csv' WITH CSV HEADER;
  \copy empleados(id_empleado,nombre,apellido_paterno,apellido_materno,rfc,fecha_contratacion,id_tienda,id_puesto,created_at,updated_at) FROM 'RUN_DIR/empleados.csv' WITH CSV HEADER;
  \copy proveedores(id_proveedor,nombre_empresa,contacto_nombre,contacto_email,contacto_telefono,created_at,updated_at) FROM 'RUN_DIR/proveedores.csv' WITH CSV HEADER;
  \copy categoria_productos(id_categoria,nombre_categoria,descripcion,created_at,updated_at) FROM 'RUN_DIR/categoria_productos.csv' WITH CSV HEADER;
  \copy productos(id_producto,sku,nombre_producto,descripcion,precio_venta,costo_compra,id_categoria,id_proveedor,created_at,updated_at) FROM 'RUN_DIR/productos.csv' WITH CSV HEADER;
  \copy clientes(id_cliente,nombre,rfc,email,telefono,created_at,updated_at) FROM 'RUN_DIR/clientes.csv' WITH CSV HEADER;
  \copy venta(id_venta,fecha_hora,monto_total,id_cliente,id_empleado,id_tienda,created_at,updated_at) FROM 'RUN_DIR/venta.csv' WITH CSV HEADER;
  \copy detalles_venta(id_detalle_venta,id_venta,id_producto,cantidad,precio_unitario,subtotal,created_at,updated_at) FROM 'RUN_DIR/detalles_venta.csv' WITH CSV HEADER;
  \copy inventario(id_tienda,id_producto,cantidad,fecha_ultima_actualizacion,updated_at) FROM 'RUN_DIR/inventario.csv' WITH CSV HEADER;
  \copy compra(id_compra,fecha_compra,id_proveedor,id_tienda,total_compra,estado,recibida,aplicada,fecha_recepcion,created_at,updated_at) FROM 'RUN_DIR/compra.csv' WITH CSV HEADER;
  \copy compra_producto(id_compra_producto,id_compra,id_producto,id_tienda,cantidad,precio_unitario,subtotal,created_at,updated_at) FROM 'RUN_DIR/compra_producto.csv' WITH CSV HEADER;
  \copy facturacion(id_factura,id_venta,serie,folio,fecha_emision,total,metodo_pago,estado,xml_path,pdf_path,created_at,updated_at) FROM 'RUN_DIR/facturacion.csv' WITH CSV HEADER;
  ```

  Orden recomendado de carga

  Para respetar las FK y evitar errores de integridad, carga los archivos en este orden:

  1. `tiendas.csv`
  2. `puesto_empleados.csv`
  3. `empleados.csv`
  4. `proveedores.csv`
  5. `categoria_productos.csv`
  6. `productos.csv`
  7. `clientes.csv`
  8. `venta.csv`
  9. `detalles_venta.csv`
  10. `inventario.csv`
  11. `compra.csv`
  12. `compra_producto.csv`
  13. `facturacion.csv`

  Reglas y formato de los CSVs generados

  - Cabeceras exactas: cada CSV incluye una fila de cabecera con los nombres de columna.
  - IDs: las columnas de ID se generan secuencialmente para facilitar `\copy` directo.
  - Fechas/timestamps: formato `YYYY-MM-DD HH:MM:SS` (sin zona).
  - Números: punto decimal con dos decimales (ej. `199.99`).
  - `subtotal` y otras columnas `GENERATED` se incluyen en los CSVs para facilitar verificaciones locales. Si tu servidor PostgreSQL
    no acepta inserción directa en columnas `GENERATED`, omítelas al importar y deja que la BD las calcule.

  Notas sobre contenido generado

  - `venta.csv`: por defecto genera 3000 filas (configurable en el script). Cada `monto_total` coincide con la suma
    de los `subtotal` en `detalles_venta` para ese `id_venta`.
  - `detalles_venta.csv`: contiene las líneas de venta (en mis ejecuciones de ejemplo ~5268 filas).
  - `inventario.csv`: se generan filas para un subconjunto de pares tienda/producto (aprox. 40% de combinaciones) con cantidades aleatorias.
  - `facturacion.csv`: se generan facturas para aproximadamente el 70% de las ventas.
  - `compra.csv` y `compra_producto.csv`: se generan compras de ejemplo (ej. 200 compras) con líneas; algunas compras se marcan `recibida=true` y `aplicada=true`.

  Consejos operativos

  - Si prefieres un único directorio con los CSVs (sin subcarpetas run_), ejecuta el script con `--out-dir` apuntando a la carpeta deseada.
  - Para automatizar pruebas posteriores, considera crear un archivo `LATEST` dentro de la carpeta base que apunte a la última ejecución — puedo añadir esto al script si quieres.
  - Si deseas que el script aplique las compras al `inventario` (simular el trigger) durante la generación, puedo añadir la lógica que "mergea" las filas de compra en `inventario.csv`.

  ---

  Si quieres, actualizo el script para crear un archivo `LATEST` con la ruta de la última ejecución y/o para aplicar automáticamente las compras al inventario. ¿Cuál prefieres?

  ```
