# Modelo Lógico — Proyecto (README de respaldo)

Este archivo es un README de respaldo que resume el propósito del repositorio, su estructura y los pasos
rápidos para ejecutar las pruebas, generar diagramas y usar los scripts que acompañan al modelo lógico.

Si necesitas la copia original completa del README, solicítala y la coloco aquí tal cual.

## Resumen del proyecto

Repositorio con el modelo lógico (DDL) de un sistema de ventas y compras. Contiene:

- DDL canonical (`sql/modelo_logico.sql`) con tablas, índices y triggers/funciones.
- PlantUML source (`diagrams/modelo_logico.puml`) y scripts para generar PNG.
- Documentación técnica en `docs/` y `out/` (PDFs para presentación).
- Scripts de ayuda en `scripts/` (ej. `generate_diagram.cmd`).
- Tests y datos de ejemplo en `tests/` y `tests/data/` (CSV generator y wrapper Windows).

## Estructura principal

- `sql/` — Contiene `modelo_logico.sql` (DDL completo).
- `diagrams/` — PlantUML `.puml` fuente y resultados exportados.
- `docs/` — Documentación Markdown (tablas, README de tests, presentación).
- `scripts/` — Scripts auxiliares (ej. `generate_diagram.cmd`).
- `tests/` — Generadores de CSV, SQL de tests y `run_tests.cmd`.
- `out/` — Exportados para presentación (`README.pdf`, `README_tests.pdf`, `tablas_modelo_logico.pdf`).

## Cómo ejecutar las pruebas (Windows / cmd.exe)

1. Edita `tests/run_tests.cmd` y ajusta las variables `USER` y `DB` según tu entorno.
2. Abre `cmd.exe` y ejecuta:

    ```bat
    tests\run_tests.cmd
    ```

   El wrapper intentará crear la BD, aplicar `sql/modelo_logico.sql` y ejecutar `tests/test_data.sql`.

## Generar el diagrama PlantUML

1. Coloca `plantuml.jar` dentro de la carpeta `scripts/` o instala PlantUML en tu PATH.
2. Ejecuta en `cmd.exe`:

    ```bat
    scripts\generate_diagram.cmd
    ```

   Esto generará `diagrams/modelo_logico.png` (requiere Java instalado; se comprobó que Java está presente en
   el entorno del autor).

## CSVs de prueba

`tests/generate_csvs.py` genera CSVs en `tests/data/` usados por los tests. Para ejecutarlo:

```bat
python tests\generate_csvs.py
```

## Regenerar PDFs / Presentación

Si quieres regenerar los PDFs en `out/`, podemos usar `pandoc` para convertir los MD a PDF. Requiere que
`pandoc` esté instalado en tu máquina. Dime si quieres que lo genere y si autorizas la instalación de herramientas.

## Notas y recomendaciones

- El archivo `docs/README_tests.md` ahora contiene instrucciones legibles y rutas relativas (más portables que
  las rutas absolutas que aparecen en la versión PDF en `out/`).
- He intentado mantener las rutas relativas en los scripts; revisa `tests/run_tests.cmd` si vas a ejecutar
  desde otra cuenta de Windows.
- Si prefieres que incluya las rutas absolutas del autor para la presentación, indícamelo y las añadiré como
  una sección separada.

---

Si quieres que copie la versión original exacta de `README.md` aquí o que genere PDF/HTML para esta versión,
dímelo y lo hago inmediatamente.
