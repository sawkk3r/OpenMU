# Script para monitorar conexões ao servidor OpenMU
# Executa: powershell -ExecutionPolicy Bypass -File monitorar-conexoes.ps1

param(
    [int]$IntervaloSegundos = 5,
    [switch]$ApenasNovas
)

$historico = @()

function Mostrar-Dashboard {
    Clear-Host
    Write-Host "=== Monitoramento de Conexoes OpenMU ===" -ForegroundColor Cyan
    Write-Host "Data/Hora: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Yellow
    Write-Host "Intervalo de atualização: $IntervaloSegundos segundos" -ForegroundColor Gray
    Write-Host ""
    
    # Status dos containers
    Write-Host "Status dos Servidores:" -ForegroundColor Green
    $containers = docker compose -f deploy/all-in-one/docker-compose.yml ps 2>$null
    $containers | ForEach-Object { 
        if ($_ -match "Up") {
            Write-Host $_ -ForegroundColor Green
        } elseif ($_ -match "Exit") {
            Write-Host $_ -ForegroundColor Red
        } else {
            Write-Host $_
        }
    }
    
    Write-Host ""
    Write-Host "Conexões Recentes (últimas 10):" -ForegroundColor Green
    Write-Host "----------------------------------------" -ForegroundColor Gray
    
    # Buscar logs recentes de conexões
    $logs = docker compose -f deploy/all-in-one/docker-compose.yml logs --tail 50 openmu-startup 2>$null
    $conexoes = $logs | Select-String -Pattern "connected|disconnected|Client.*requested" | Select-Object -Last 10
    
    if ($conexoes) {
        foreach ($conexao in $conexoes) {
            if ($conexao -match "connected") {
                Write-Host "[OK] $conexao" -ForegroundColor Green
            } elseif ($conexao -match "disconnected") {
                Write-Host "[X] $conexao" -ForegroundColor Red
            } else {
                Write-Host "[>] $conexao" -ForegroundColor Cyan
            }
        }
    } else {
        Write-Host "Nenhuma conexao recente" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "Conexões Ativas nas Portas:" -ForegroundColor Green
    Write-Host "----------------------------------------" -ForegroundColor Gray
    
    # Verificar conexões estabelecidas
    $portas = @{
        "ConnectServer (44405)" = 44405
        "ConnectServer (44406)" = 44406
        "GameServer 1 (55901)" = 55901
        "GameServer 2 (55902)" = 55902
        "GameServer 3 (55903)" = 55903
        "ChatServer (55980)" = 55980
    }
    
    foreach ($portaInfo in $portas.GetEnumerator()) {
        $conexoesAtivas = (netstat -an 2>$null | Select-String ":$($portaInfo.Value)" | Select-String "ESTABLISHED" | Measure-Object).Count
        if ($conexoesAtivas -gt 0) {
            Write-Host "$($portaInfo.Key): $conexoesAtivas conexao(oes)" -ForegroundColor Green
        } else {
            Write-Host "$($portaInfo.Key): 0 conexoes" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Write-Host "Pressione Ctrl+C para sair" -ForegroundColor Yellow
}

# Loop principal
try {
    while ($true) {
        Mostrar-Dashboard
        Start-Sleep -Seconds $IntervaloSegundos
    }
} catch {
    Write-Host ""
    Write-Host "Monitoramento interrompido." -ForegroundColor Yellow
    exit 0
}
