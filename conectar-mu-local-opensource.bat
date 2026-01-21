@echo off
REM Script para conectar ao servidor MU Online local (Cliente Open Source)
REM Use este script se o cliente e servidor estao na mesma maquina

echo ========================================
echo Conectando ao Servidor MU Online Local
echo (Cliente Open Source)
echo ========================================
echo.
echo IP: 127.127.127.127
echo Porta: 44406
echo.

REM Substitua o caminho abaixo pelo caminho real do seu main.exe
set MAIN_EXE=C:\Caminho\Para\Seu\MU\main.exe

REM Verifica se o arquivo existe
if not exist "%MAIN_EXE%" (
    echo ERRO: Arquivo main.exe nao encontrado!
    echo Por favor, edite este script e configure o caminho correto.
    echo.
    pause
    exit /b 1
)

REM Conecta usando porta 44406 (Cliente Open Source)
echo Conectando na porta 44406 (Cliente Open Source)...
start "" "%MAIN_EXE%" connect /u127.127.127.127 /p44406

echo.
echo Cliente iniciado!
echo.
pause
