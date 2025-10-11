# Guía rápida para presentar el proyecto Model_logic

Objetivo: dar a los revisores una ruta clara para revisar el modelo lógico, el DDL, los diagramas y las pruebas.

Archivos clave y orden de revisión

1. Documentación y estructura
   - `docs/STRUCTURE.md` — mapa del repo y decisiones de organización.
   - `docs/tablas_modelo_logico.md` — explicación tabla por tabla.
   - `docs/README_tests.md` — cómo ejecutar las pruebas en Windows.

2. DDL y Diagrama
   - `sql/modelo_logico.sql` — lee el DDL y verifica triggers y constraints.
   - `diagrams/modelo_logico.puml` — diagrama ER; si quieres, genera PNG/SVG y muéstralo durante la presentación.

3. Pruebas y datos
   - `tests/test_data.sql` — script de pruebas con inserciones y asserts.
   - `tests/generate_csvs.py` — genera CSVs realistas (3000 ventas por defecto).
   - `tests/data/` — CSVs generados listos para `\copy`.

4. Scripts de utilidad
   - `tests/run_tests.cmd` — wrapper para Windows que crea BD, aplica DDL y ejecuta los tests.

## Generar la imagen del diagrama (modelo_logico.png)

Recomendado para la demo: generar `diagrams/modelo_logico.png` desde el archivo PlantUML.

Pasos rápidos (Windows):

1. Descarga `plantuml.jar` desde https://plantuml.com/es/download y coloca el archivo en `scripts\` del proyecto.
2. Asegúrate de tener Java instalado (ejecuta `java -version`).
3. Ejecuta el script desde la raíz del proyecto en cmd.exe:

```cmd
cd /d "%CD%"  REM asegúrate de estar en la raíz del proyecto
cd scripts
generate_diagram.cmd
```

El script generará `diagrams\modelo_logico.png`.

Si prefieres no descargar nada, puedo generar la imagen y añadirla al repo si me autorizas a descargar `plantuml.jar` (necesita acceso a internet) — dime si lo hago por ti o prefieres descargarlo localmente.

Sugerencia de demo en vivo (5-10 minutos)

- Mostrar diagrama `diagrams/modelo_logico.puml` (convertido a PNG) al inicio para dar contexto.
- Abrir `sql/modelo_logico.sql` y explicar rápidamente las tablas más relevantes (`venta`, `detalles_venta`, `compra`, `compra_producto`, `inventario`) y los triggers clave (recalculo de montos y aplicación a inventario).
- Ejecutar en vivo (o con captura de pantalla) `tests/run_tests.cmd` para mostrar que los tests pasan y los asserts no fallan.
- Opcional: cargar un par de CSVs desde `tests/data/` usando `\copy` para demostrar la importación masiva y cómo respeta las FK.

Notas para reviewers

- El código está organizado para presentación; si se desea que se muevan (no copien) los archivos a las nuevas carpetas, se puede hacer y yo puedo actualizar referencias en scripts.
- Si el target de BD es Postgres <12, hay que convertir columnas `GENERATED` a triggers; lo puedo hacer de forma automatizada.

