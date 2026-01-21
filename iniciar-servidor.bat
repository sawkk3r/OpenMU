@echo off
echo ========================================
echo Iniciando Servidor OpenMU
echo ========================================
echo.

cd /d "%~dp0"
cd deploy\all-in-one

echo Iniciando containers Docker...
echo.

docker compose up -d --no-build

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Servidor iniciado com sucesso!
    echo ========================================
    echo.
    echo Aguarde alguns segundos para inicializacao completa.
    echo.
    echo Acesse o painel administrativo em:
    echo http://localhost/
    echo.
    echo Usuario: admin
    echo Senha: openmu
    echo.
    echo Para ver os logs:
    echo docker compose logs -f openmu-startup
    echo.
) else (
    echo.
    echo ERRO ao iniciar o servidor!
    echo Verifique se o Docker Desktop esta rodando.
    echo.
)

pause
