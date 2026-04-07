@echo off
setlocal

:: Configurações
set EXE_NAME="Instalador Apps Padrao"
set ICON_FILE=assets\icon.ico
set SCRIPT_FILE=src\main.py
set SCRIPTS_DIR=scripts
set CONFIG_DIR=config

echo ======================================================
echo Iniciando o processo de build para: %EXE_NAME%
echo ======================================================

:: Verificar se o PyInstaller está instalado
pyinstaller --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] PyInstaller nao encontrado. Instale-o com: pip install pyinstaller
    pause
    exit /b %errorlevel%
)

:: Limpar pastas antigas para garantir um build limpo
if exist build rd /s /q build
if exist dist rd /s /q dist

echo.
echo [1/3] Gerando o executavel...
:: --add-data "origem;destino" (no Windows usa ;)
pyinstaller --onefile ^
    -n %EXE_NAME% ^
    --icon=%ICON_FILE% ^
    --add-data "%SCRIPTS_DIR%;scripts" ^
    --add-data "%CONFIG_DIR%;config" ^
    --clean ^
    %SCRIPT_FILE%

if %errorlevel% neq 0 (
    echo.
    echo [ERRO] Ocorreu um problema durante o build.
    pause
    exit /b %errorlevel%
)

echo.
echo [2/3] Limpando arquivos temporarios...
if exist build rd /s /q build
if exist *.spec del /q *.spec

echo.
echo [3/3] Build concluido com sucesso!
echo O executavel esta disponivel na pasta 'dist/'.
echo.

pause
endlocal