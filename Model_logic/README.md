# Modelo lógico (sistema de ventas) — Model_logic

Este repositorio contiene el modelo lógico extraído de las imágenes proporcionadas (tiendas, puestos, empleados, proveedores, categorías, productos, inventario, clientes, venta y detalles_venta), ahora extendido para soportar compras a proveedores y facturación.

Archivos principales
- `modelo_logico.sql` — DDL en PostgreSQL con las tablas, índices, funciones y triggers (ubicado en la raíz del proyecto).
- `modelo_logico.puml` — Diagrama ER en PlantUML. Ábrelo con la extensión PlantUML en VS Code o genera imágenes con PlantUML.
- `tablas_modelo_logico.md` — Documentación en Markdown con cada tabla, campos, índices y notas (incluye ejemplo SQL de flujo de compra).
- `tests/test_data.sql` — Script de pruebas que inserta datos y ejecuta comprobaciones automáticas (RAISE EXCEPTION) para validar triggers y reglas de negocio.
- `tests/run_tests.cmd` — Wrapper Windows para crear la BD, aplicar el DDL y ejecutar las pruebas.
- `README_tests.md` — Instrucciones y resultados esperados para las pruebas.
- `conversacion_resumen.md` — Resumen de la sesión y cambios realizados.

Cambios y supuestos principales
- Se añadieron las entidades `compra` y `compra_producto` (lógica para compras a proveedores).
- Para la recepción de una compra existen columnas de control: `recibida` (cuando se confirma la recepción) y `aplicada` (para prevenir dobles aplicaciones al inventario).
- `inventario` sigue con PK compuesta `(id_tienda, id_producto)`.
- Dialecto: PostgreSQL (se usan `SERIAL`, `timestamp`, `numeric`, y columnas `GENERATED` para subtotales). Si necesitas compatibilidad con PostgreSQL <12 puedo convertir `GENERATED` en triggers.
- Se añadieron triggers: auditoría (`updated_at`), recálculo automático de `venta.monto_total`, recálculo de `compra.total_compra`, y aplicación de líneas de compra al inventario al confirmar recepción.

Estructura de carpetas y archivos
---------------------------------
Raíz:
- `modelo_logico.sql` (DDL principal)
- `modelo_logico.puml` (diagrama PlantUML)
- `tablas_modelo_logico.md`, `conversacion_resumen.md`, `README.md`
- `run_tests.cmd` (wrapper que llama a `tests\run_tests.cmd`)

Carpeta `tests`:
- `tests\test_data.sql` — inserciones y SELECTs para validar triggers y facturación; contiene comprobaciones automáticas que fallan con excepción en caso de discrepancia.
- `tests\run_tests.cmd` — script para Windows (cmd.exe) que crea la BD, aplica el DDL y ejecuta las pruebas.

Cómo ejecutar los tests (Windows, cmd.exe)
----------------------------------------
1) Edita `tests\run_tests.cmd` y ajusta la variable `USER` con tu usuario de Postgres (ejemplo: `SET USER=postgres`).
2) Desde la raíz del proyecto ejecuta el wrapper:

```cmd
cd "c:\Users\vegas\OneDrive\Desktop\Model_logic"
run_tests.cmd
```

O ejecuta directamente el script dentro de `tests`:

```cmd
cd "c:\Users\vegas\OneDrive\Desktop\Model_logic\tests"
run_tests.cmd
```

Notas sobre los tests
- Los `DO $$ ... $$;` incluidos en `tests/test_data.sql` lanzan `RAISE EXCEPTION` si una comprobación falla; por tanto la ejecución retornará error (código distinto de 0) cuando algo no coincida.
- Los checks cubren: recálculo de `venta.monto_total`, coincidencia de `facturacion.total`, recálculo de `compra.total_compra`, aplicación al `inventario` y idempotencia de la recepción.

PlantUML y renderizado
----------------------
- Si PlantUML lanza errores al renderizar, abre `modelo_logico.puml` y verifica que no haya alias duplicados. En este proyecto la entidad alias de las líneas de compra fue renombrada a `CompraItem` internamente para evitar colisiones; la semántica sigue siendo la misma.
- Recomendación: usa la extensión PlantUML en VS Code o la CLI de PlantUML (asegúrate de tener Java y Graphviz si usas la versión local).

Compatibilidad y recomendaciones
--------------------------------
- PostgreSQL >= 12 recomendado por el uso de columnas `GENERATED`.
- Para entornos de producción considera:
  - Añadir `created_by` / `updated_by` para auditoría por usuario.
  - Registrar movimientos en una tabla `movimiento_inventario` si necesitas trazabilidad completa por lote/serie.
  - Tests automatizados en CI: convertir los asserts a un script que devuelva salida estructurada (JSON) o usar una suite (pytest + psycopg2) para integración continua.

Contacto y siguientes pasos
--------------------------
- Si quieres que convierta las columnas `GENERATED` a triggers para compatibilidad con Postgres <12, lo hago.
- ¿Quieres que suba un commit preparado y un mensaje sugerido para hacer push a GitHub? Puedo generar el mensaje de commit y el cuerpo del PR.

Gracias — si quieres que haga alguna otra actualización (limpieza del PUML, cambios de nombres, o añadir más tests/CI), dime y lo implemento.

