# Model_logic — Sistema de Ventas (PostgreSQL)

Proyecto de modelo lógico para un sistema de ventas y compras en PostgreSQL. Incluye DDL completo (tablas, claves, triggers), diagrama ER en PlantUML, generador de CSVs realistas, y un script de pruebas automatizadas para verificar comportamientos clave (cálculo de montos, facturación, compras → inventario, e idempotencia).

- DDL: `sql/modelo_logico.sql`
- Diagrama ER: `diagrams/modelo_logico.puml` (PNG opcional)
- Pruebas: `tests/test_data.sql` + `tests/run_tests.cmd`
- Generador CSV: `tests/generate_csvs.py` (salida en `tests/data/run_YYYYMMDD_HHMMSS`)
- Documentación: `docs/tablas_modelo_logico.md`, `docs/README_tests.md`, `docs/PRESENTATION.md`

## Requisitos

- PostgreSQL ≥ 12 (recomendado 16/18)
- Cliente psql en PATH (o usar `tests/run_tests_local.cmd` que incluye ruta absoluta configurable)
- Opcional (diagramas): Java + `plantuml.jar`
- Opcional (datos): Python 3.10+ (el generador usa librerías estándar)

## Quickstart (Windows / cmd.exe)

1) Configurar usuario/BD en `tests/run_tests.cmd` y ejecutar:

```bat
rem Edita USER y DB al inicio del script según tu entorno
rem SET USER=postgres
rem SET DB=tienda_dev

tests\run_tests.cmd
```

¿Sin psql en PATH? Usa el wrapper local (edita ruta a `psql.exe` en el archivo si es necesario):

```bat
tests\run_tests_local.cmd
```

Para evitar el prompt de contraseña en una sesión (menos seguro):

```bat
set PGPASSWORD=TU_PASSWORD
tests\run_tests_local.cmd
set PGPASSWORD=
```

El flujo aplica el DDL y ejecuta `tests/test_data.sql` (inserciones + asserts). Si una comprobación falla verás un `RAISE EXCEPTION` con detalle.

## Generar datos CSV de ejemplo

Crea datos realistas para 13 tablas en una subcarpeta con sello de tiempo.

```bat
python tests\generate_csvs.py
```

- Salida por defecto: `tests\data\run_YYYYMMDD_HHMMSS\`
- Personalizar carpeta base:

```bat
python tests\generate_csvs.py --out-dir C:\ruta\a\mis\csvs
```

Cargar CSVs con `\copy` (ejemplo; reemplaza RUN_DIR por tu carpeta):

```sql
\copy tiendas(...)             FROM 'RUN_DIR/tiendas.csv' WITH CSV HEADER;
\copy puesto_empleados(...)    FROM 'RUN_DIR/puesto_empleados.csv' WITH CSV HEADER;
\copy empleados(...)           FROM 'RUN_DIR/empleados.csv' WITH CSV HEADER;
\copy proveedores(...)         FROM 'RUN_DIR/proveedores.csv' WITH CSV HEADER;
\copy categoria_productos(...) FROM 'RUN_DIR/categoria_productos.csv' WITH CSV HEADER;
\copy productos(...)           FROM 'RUN_DIR/productos.csv' WITH CSV HEADER;
\copy clientes(...)            FROM 'RUN_DIR/clientes.csv' WITH CSV HEADER;
\copy venta(...)               FROM 'RUN_DIR/venta.csv' WITH CSV HEADER;
\copy detalles_venta(...)      FROM 'RUN_DIR/detalles_venta.csv' WITH CSV HEADER;
\copy inventario(...)          FROM 'RUN_DIR/inventario.csv' WITH CSV HEADER;
\copy compra(...)              FROM 'RUN_DIR/compra.csv' WITH CSV HEADER;
\copy compra_producto(...)     FROM 'RUN_DIR/compra_producto.csv' WITH CSV HEADER;
\copy facturacion(...)         FROM 'RUN_DIR/facturacion.csv' WITH CSV HEADER;
```

Más detalles en `tests/data/Values.md`.

## Diagrama ER (PlantUML)

1) Descarga `plantuml.jar` y colócalo en `scripts/` (https://plantuml.com/download)
2) Asegúrate de tener Java disponible (`java -version`)
3) Genera la imagen PNG:

```bat
scripts\generate_diagram.cmd
```

La salida se guarda en `diagrams\modelo_logico.png`.

## Estructura del repositorio

```
sql/           # DDL canónico (modelo_logico.sql)
diagrams/     # Diagrama ER (puml) y artefactos exportados
docs/         # Documentación (tablas, guía de pruebas, presentación)
tests/        # Pruebas SQL, wrapper cmd y generador de CSVs
  └─ data/    # Salida de CSVs (subcarpetas run_YYYYMMDD_HHMMSS)
scripts/      # Utilidades (e.g., generate_diagram.cmd)
out/          # Artefactos listos para presentación (PDF/PNG opcional)
```

## Documentación

- Tablas y relaciones: [`docs/tablas_modelo_logico.md`](docs/tablas_modelo_logico.md)
- Cómo ejecutar pruebas: [`docs/README_tests.md`](docs/README_tests.md)
- Guía de presentación: [`docs/PRESENTATION.md`](docs/PRESENTATION.md)

## Solución de problemas

- “psql no encontrado”: añade `C:\Program Files\PostgreSQL\<ver>\bin` a PATH o usa `tests\run_tests_local.cmd` (edita la ruta interna).
- PostgreSQL < 12: sustituye columnas `GENERATED` por triggers (puedo proporcionar variante del DDL).
- Permisos al crear BD: ejecuta con un rol que tenga privilegios (`createdb`) o crea la BD manualmente y vuelve a lanzar el script.

## Licencia


---

