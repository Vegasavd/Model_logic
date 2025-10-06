# Modelo lógico (sistema de ventas) — Model_logic

Este repositorio contiene el modelo lógico extraído de las imágenes proporcionadas (tiendas, puestos, empleados, proveedores, categorías, productos, inventario, clientes, venta y detalles_venta).

Archivos principales
- `modelo_logico.sql` — DDL en PostgreSQL con las tablas y relaciones (ubicado en la raíz del proyecto).
- `modelo_logico.puml` — Diagrama ER en PlantUML. Puedes abrirlo en VS Code con la extensión PlantUML o generar imágenes con PlantUML.
- `tablas_modelo_logico.md` — Documentación en Markdown con las tablas y sus campos.
- `conversacion_resumen.md` — Resumen de la sesión y cambios realizados.

Cambios y supuestos principales
- Se renombraron algunas entidades/atributos para consistencia (por ejemplo `categoria_productos`, `detalles_venta`).
- `inventario` tiene clave primaria compuesta `(id_tienda, id_producto)`.
- Dialecto: PostgreSQL (`SERIAL`, `timestamp`, `numeric`). Puedo adaptar a MySQL/SQL Server si lo prefieres.
- Se añadieron columnas y triggers para auditoría y para mantener `venta.monto_total` actualizado desde `detalles_venta`.

Tests y estructura de carpetas
--------------------------------
He movido los scripts de prueba a la carpeta `tests` para mantenerlos centralizados. Estructura actual relevante:

- Raíz:
  - `modelo_logico.sql` (DDL principal)
  - `modelo_logico.puml` (diagrama PlantUML)
  - `tablas_modelo_logico.md`, `conversacion_resumen.md`, `README.md`
  - `run_tests.cmd` (wrapper que llama a `tests\run_tests.cmd`)

- Carpeta `tests`:
  - `tests\test_data.sql` — inserciones y SELECTs para validar triggers y facturación.
  - `tests\run_tests.cmd` — script para Windows (cmd.exe) que crea la BD, ejecuta el DDL y ejecuta las pruebas.

Cómo ejecutar los tests (Windows, cmd.exe)
1. Opcional: editar `tests\run_tests.cmd` y ajustar la variable `USER` con tu usuario de Postgres.
2. Desde la raíz del proyecto ejecuta el wrapper (llama al script dentro de `tests`):

```cmd
cd "c:\Users\vegas\OneDrive\Desktop\Model_logic"
run_tests.cmd
```

O bien, puedes ejecutar directamente el script dentro de `tests`:

```cmd
cd "c:\Users\vegas\OneDrive\Desktop\Model_logic\tests"
run_tests.cmd
```

