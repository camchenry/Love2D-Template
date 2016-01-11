@echo OFF
set mydir="%~p0"
SET mydir=%mydir:\=;%

for /F "tokens=* delims=;" %%i IN (%mydir%) DO call :LAST_FOLDER %%i
goto :EOF

:LAST_FOLDER
if "%1"=="" (
    @echo Running %LAST% project
    "%PROGRAMFILES%\LOVE\love" ..\%LAST%
    exit
)

set LAST=%1
SHIFT

goto :LAST_FOLDER