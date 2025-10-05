# Modelo lógico (sistema de ventas) — Model_logic

Este repositorio contiene el modelo lógico extraído de las imágenes proporcionadas (tiendas, puestos, empleados, proveedores, categorías, productos, inventario, clientes, venta y detalles_venta).

Archivos principales:
- `modelo_logico.sql` — DDL en PostgreSQL con las tablas y relaciones tal como aparecen en las imágenes. Incluye claves primarias, foráneas, índices y notas para triggers.
- `modelo_logico.puml` — Diagrama ER en PlantUML. Puedes abrirlo en VS Code con la extensión PlantUML (recomendada: PlantUML de jebbs) o generar imágenes con PlantUML.

Cambios y supuestos principales:
- Se renombraron algunas entidades/atributos para consistencia (por ejemplo `categoria_productos`, `detalles_venta`).
- `inventario` tiene clave primaria compuesta `(id_tienda, id_producto)` tal como se indica en las imágenes.
- Dialecto: PostgreSQL (`SERIAL`, `timestamp`, `numeric`). Si prefieres MySQL/SQL Server lo adapto.
- Se añadió columna `fecha_ultima_actualizacion` en `inventario` y `fecha_hora` en `venta`.
- Se sugiere implementar triggers para mantener `venta.monto_total` actualizado desde `detalles_venta`.

Siguientes pasos sugeridos:
- ¿Quieres que genere la imagen `modelo_logico.png` o `modelo_logico.svg` y la guarde en la carpeta? (puedo hacerlo).
- Añadir campos de auditoría (`created_at`, `updated_at`, `created_by`) si lo requieres.
- Añadir constraints adicionales (uniqueness, checks) según reglas de negocio.

Si detectas algún nombre distinto en las imágenes o prefieres otro dialecto SQL, dime y hago la adaptación.
