# Estructura propuesta del proyecto Model_logic

Objetivo: organizar el repo para presentación y facilidad de uso, manteniendo compatibilidad con los scripts existentes.

Nueva estructura (alta prioridad):

- /sql
  - `modelo_logico.sql`  -> DDL principal (copia de la raíz para claridad)
- /diagrams
  - `modelo_logico.puml` -> PlantUML (diagrama fuente)
  - `modelo_logico.png`  -> Imagen generada (opcional)
- /docs
  - `tablas_modelo_logico.md`
  - `README_tests.md`
  - `conversacion_resumen.md`
  - `STRUCTURE.md` (este archivo)
- /tests
  - `test_data.sql`
  - `test_ordenes.sql` (scripts ad-hoc)
  - `run_tests.cmd`
  - `generate_csvs.py`
  - /data
    - CSVs para `
- /scripts
  - utilitarios y wrappers (por ejemplo `run_tests.cmd` o scripts de despliegue)
- /out
  - exportes PDF/PNG generados

Notas de implementación
- Para evitar romper paths existentes, se dejarán las copias en la raíz y además se copiarán versiones a `sql/`, `diagrams/` y `docs/`.
- Si prefieres mover en lugar de copiar, lo hacemos; por ahora usamos copias para preservar los procesos actuales.

Qué contiene cada carpeta
- `sql/` 	: DDL y migraciones.
- `diagrams/` : PlantUML y artefactos visuales.
- `docs/` : Documentación legible (MD/PDF), instrucciones para reviewers.
- `tests/` : Scripts de prueba y data de soporte.
- `scripts/` : Utilidades para desarrollo, despliegue y CI.

Siguientes pasos sugeridos
1. Revisar `STRUCTURE.md` y decir si quieres que realice `move` (mover archivos) en lugar de `copy`.
2. Generar la imagen `modelo_logico.png` desde `modelo_logico.puml` y ubicarla en `diagrams/`.
3. Actualizar `README.md` para referenciar la nueva estructura y comandos de uso.

