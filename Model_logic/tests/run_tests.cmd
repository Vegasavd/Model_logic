@echo off
REM Script para ejecutar el DDL y los tests en Windows (cmd.exe)
REM Ajusta USER y DB_NAME según tu entorno
set USER=tu_usuario
set DB=tienda_dev

REM Crear base de datos (si es necesario)
psql -U %USER% -c "CREATE DATABASE %DB%;"

REM Ejecutar DDL (En su defecto las rutas donde tu guardes el archivo)
psql -U %USER% -d %DB% -f "c:\Users\vegas\OneDrive\Desktop\Model_logic\modelo_logico.sql"

REM Ejecutar script de pruebas  (En su defecto las rutas donde tu guardes el archivo)
psql -U %USER% -d %DB% -f "c:\Users\vegas\OneDrive\Desktop\Model_logic\tests\test_data.sql"

echo Tests ejecutados. Revisa la salida anterior para verificar los resultados.
pause
