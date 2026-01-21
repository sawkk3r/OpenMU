# Script PowerShell para conectar ao servidor MU Online
# Use este script se o cliente e servidor estao na mesma rede

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Conectando ao Servidor MU Online" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuracoes - AJUSTE AQUI
$MainExePath = "C:\Caminho\Para\Seu\MU\main.exe"
$ServerIP = "192.168.0.20"  # Altere para o IP do seu servidor na rede local
$Port = 44405  # Use 44405 para cliente original ou 44406 para cliente open source

Write-Host "IP do Servidor: $ServerIP" -ForegroundColor Yellow
Write-Host "Porta: $Port" -ForegroundColor Yellow
Write-Host ""

# Verifica se o arquivo existe
if (-not (Test-Path $MainExePath)) {
    Write-Host "ERRO: Arquivo main.exe nao encontrado em:" -ForegroundColor Red
    Write-Host "$MainExePath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor, edite este script e configure o caminho correto." -ForegroundColor Yellow
    Read-Host "Pressione Enter para sair"
    exit 1
}

# Inicia o cliente
Write-Host "Iniciando cliente MU Online..." -ForegroundColor Green
Write-Host ""

$arguments = @("connect", "/u$ServerIP", "/p$Port")
Start-Process -FilePath $MainExePath -ArgumentList $arguments

Write-Host "Cliente iniciado!" -ForegroundColor Green
Write-Host ""
