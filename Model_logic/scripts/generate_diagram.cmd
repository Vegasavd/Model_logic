@echo off
REM Genera diagrams/modelo_logico.png desde diagrams/modelo_logico.puml
REM Requiere plantuml.jar en la carpeta scripts\ o en la ruta especificada.

SET JAVA=java
SET PLANTUML_JAR=%~dp0plantuml.jar
IF NOT EXIST "%PLANTUML_JAR%" (
  echo No se encontro plantuml.jar en %~dp0
  echo Descarga plantuml.jar desde https://plantuml.com/es/download y colocalo en la carpeta scripts\
  exit /b 1
)

echo Generando diagrams\modelo_logico.png ...
"%JAVA%" -jar "%PLANTUML_JAR%" -tpng "%~dp0..\diagrams\modelo_logico.puml" -o "%~dp0..\diagrams\"
IF %ERRORLEVEL% NEQ 0 (
  echo Error generando la imagen. Revisa que plantuml.jar y Java esten instalados.
  exit /b 1
)

echo Imagen generada en diagrams\modelo_logico.png
pause
