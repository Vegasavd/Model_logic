@echo off
REM Script para ejecutar el DDL y los tests en Windows (cmd.exe)
REM Ajusta las variables USER y DB según tu entorno antes de ejecutar.

SETLOCAL ENABLEDELAYEDEXPANSION

SET USER=tu_usuario
SET DB=tienda_dev

echo Verificando disponibilidad de psql...
where psql >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
	echo No se encontro 'psql' en PATH. Asegurate de tener PostgreSQL cliente instalado y en PATH.
	pause
	exit /b 1
)

echo Creando base de datos %DB% (si no existe)...
psql -U %USER% -c "CREATE DATABASE %DB%;" || echo "La base ya existe o hubo un error al crearla. Revisa permisos."

echo Aplicando DDL desde modelo_logico.sql ...
psql -U %USER% -d %DB% -f "c:\Users\vegas\OneDrive\Desktop\Model_logic\modelo_logico.sql"
IF %ERRORLEVEL% NEQ 0 (
	echo Error aplicando DDL. Revisa la salida anterior.
	pause
	exit /b 1
)

echo Ejecutando pruebas (test_data.sql)...
psql -U %USER% -d %DB% -f "c:\Users\vegas\OneDrive\Desktop\Model_logic\tests\test_data.sql"
IF %ERRORLEVEL% NEQ 0 (
	echo Error ejecutando pruebas. Revisa la salida anterior.
	pause
	exit /b 1
)

echo Tests ejecutados. Revisa la salida anterior para verificar los resultados.
pause
ENDLOCAL
