@echo off
REM Wrapper that calls tests/run_tests.cmd but forces the full path to psql (useful when psql not in PATH)

SET PSQL_PATH="C:\Program Files\PostgreSQL\16\bin\psql.exe"

SET USER=postgres
SET DB=tienda_dev

echo This script will run DDL and tests using %PSQL_PATH%
echo If your postgres user or DB are different, edit this file before running.

echo Creating database %DB% (if not exists)...
%PSQL_PATH% -U %USER% -c "CREATE DATABASE %DB%;" || echo "The database may already exist or creation failed."

echo Applying DDL...
SET SCRIPT_DIR=%~dp0..\
%PSQL_PATH% -U %USER% -d %DB% -f "%SCRIPT_DIR%sql\modelo_logico.sql"
IF %ERRORLEVEL% NEQ 0 (
    echo Error applying DDL. Check output.
    pause
    exit /b 1
)

echo Running tests...
%PSQL_PATH% -U %USER% -d %DB% -f "%~dp0test_data.sql"
IF %ERRORLEVEL% NEQ 0 (
    echo Error running tests. Check output.
    pause
    exit /b 1
)

echo Tests executed. Review output above for results.
pause
