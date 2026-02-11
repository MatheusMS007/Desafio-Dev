# =============================================
# Script de Gerenciamento da Aplicação
# DesafioCrud API
# =============================================

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("status", "start", "stop", "restart", "test", "logs")]
    [string]$Action = "status"
)

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GERENCIADOR - DesafioCrud API" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Função para verificar se a API está rodando
function Test-ApiRunning {
    try {
        $response = Invoke-WebRequest -Uri "https://localhost:5001/health" -SkipCertificateCheck -TimeoutSec 2 -ErrorAction SilentlyContinue
        return $response.StatusCode -eq 200
    }
    catch {
        return $false
    }
}

# Função para encontrar processo na porta
function Get-ProcessOnPort {
    param([int]$Port)
    
    $netstat = netstat -ano | Select-String ":$Port"
    if ($netstat) {
        $line = $netstat[0].ToString().Trim()
        $parts = $line -split '\s+'
        $pid = $parts[-1]
        return $pid
    }
    return $null
}

# Função para parar a aplicação
function Stop-Application {
    Write-Host "Procurando processos da aplicação..." -ForegroundColor Yellow
    
    # Tentar encontrar pela porta
    $pid = Get-ProcessOnPort -Port 5001
    
    if ($pid) {
        Write-Host "Encontrado processo na porta 5001 (PID: $pid)" -ForegroundColor Yellow
        try {
            Stop-Process -Id $pid -Force -ErrorAction Stop
            Write-Host "✓ Processo parado com sucesso!" -ForegroundColor Green
            Start-Sleep -Seconds 2
            return $true
        }
        catch {
            Write-Host "✗ Erro ao parar processo: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
    
    # Tentar encontrar por nome
    $processes = Get-Process | Where-Object {$_.ProcessName -like "*DesafioCrud*"}
    if ($processes) {
        Write-Host "Encontrados $($processes.Count) processo(s) DesafioCrud" -ForegroundColor Yellow
        foreach ($proc in $processes) {
            try {
                Stop-Process -Id $proc.Id -Force
                Write-Host "✓ Processo $($proc.Id) parado" -ForegroundColor Green
            }
            catch {
                Write-Host "✗ Erro ao parar processo $($proc.Id)" -ForegroundColor Red
            }
        }
        Start-Sleep -Seconds 2
        return $true
    }
    
    Write-Host "Nenhum processo encontrado" -ForegroundColor Gray
    return $false
}

# Ação: STATUS
if ($Action -eq "status") {
    Write-Host "Verificando status da aplicação..." -ForegroundColor Yellow
    Write-Host ""
    
    $isRunning = Test-ApiRunning
    
    if ($isRunning) {
        Write-Host "✓ API ESTÁ RODANDO" -ForegroundColor Green
        Write-Host ""
        Write-Host "URLs disponíveis:" -ForegroundColor White
        Write-Host "  • Health Check: https://localhost:5001/health" -ForegroundColor Cyan
        Write-Host "  • Swagger:      https://localhost:5001/swagger" -ForegroundColor Cyan
        Write-Host "  • API:          https://localhost:5001/api/contatos" -ForegroundColor Cyan
        Write-Host ""
        
        # Verificar processo
        $pid = Get-ProcessOnPort -Port 5001
        if ($pid) {
            $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "Processo:" -ForegroundColor White
                Write-Host "  • PID:  $pid" -ForegroundColor Gray
                Write-Host "  • Nome: $($process.ProcessName)" -ForegroundColor Gray
                Write-Host "  • CPU:  $([math]::Round($process.CPU, 2))s" -ForegroundColor Gray
                Write-Host "  • RAM:  $([math]::Round($process.WorkingSet64 / 1MB, 2)) MB" -ForegroundColor Gray
            }
        }
    }
    else {
        Write-Host "✗ API NÃO ESTÁ RODANDO" -ForegroundColor Red
        Write-Host ""
        Write-Host "Para iniciar, execute:" -ForegroundColor Yellow
        Write-Host "  .\Scripts\GerenciarApp.ps1 -Action start" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Ou manualmente:" -ForegroundColor Yellow
        Write-Host "  dotnet run" -ForegroundColor Cyan
    }
}

# Ação: START
elseif ($Action -eq "start") {
    Write-Host "Iniciando aplicação..." -ForegroundColor Yellow
    Write-Host ""
    
    # Verificar se já está rodando
    if (Test-ApiRunning) {
        Write-Host "✓ Aplicação JÁ ESTÁ RODANDO!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Acesse: https://localhost:5001/swagger" -ForegroundColor Cyan
        exit 0
    }
    
    Write-Host "Executando: dotnet run" -ForegroundColor Gray
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "LOGS DA APLICAÇÃO" -ForegroundColor Cyan
    Write-Host "Pressione Ctrl+C para parar" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Executar aplicação
    dotnet run
}

# Ação: STOP
elseif ($Action -eq "stop") {
    Write-Host "Parando aplicação..." -ForegroundColor Yellow
    Write-Host ""
    
    $stopped = Stop-Application
    
    if ($stopped) {
        Write-Host ""
        Write-Host "✓ Aplicação parada com sucesso!" -ForegroundColor Green
    }
    else {
        Write-Host ""
        Write-Host "✗ Aplicação não estava rodando ou não foi possível parar" -ForegroundColor Yellow
    }
}

# Ação: RESTART
elseif ($Action -eq "restart") {
    Write-Host "Reiniciando aplicação..." -ForegroundColor Yellow
    Write-Host ""
    
    # Parar
    Write-Host "[1/2] Parando aplicação..." -ForegroundColor Gray
    Stop-Application | Out-Null
    Start-Sleep -Seconds 3
    
    # Iniciar
    Write-Host "[2/2] Iniciando aplicação..." -ForegroundColor Gray
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "LOGS DA APLICAÇÃO" -ForegroundColor Cyan
    Write-Host "Pressione Ctrl+C para parar" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    dotnet run
}

# Ação: TEST
elseif ($Action -eq "test") {
    Write-Host "Testando aplicação..." -ForegroundColor Yellow
    Write-Host ""
    
    if (-not (Test-ApiRunning)) {
        Write-Host "✗ Aplicação não está rodando!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Inicie a aplicação primeiro:" -ForegroundColor Yellow
        Write-Host "  .\Scripts\GerenciarApp.ps1 -Action start" -ForegroundColor Cyan
        exit 1
    }
    
    Write-Host "✓ Aplicação está rodando" -ForegroundColor Green
    Write-Host ""
    
    # Teste 1: Health Check
    Write-Host "[TEST 1] Health Check..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "https://localhost:5001/health" -SkipCertificateCheck
        if ($response -eq "Healthy") {
            Write-Host "✓ PASSOU - Health check retornou: $response" -ForegroundColor Green
        }
        else {
            Write-Host "✗ FALHOU - Resposta inesperada: $response" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "✗ FALHOU - Erro: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""
    
    # Teste 2: Listar Contatos
    Write-Host "[TEST 2] Listar Contatos..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "https://localhost:5001/api/contatos" -SkipCertificateCheck
        Write-Host "✓ PASSOU - Retornou $($response.Count) contato(s)" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ FALHOU - Erro: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""
    
    # Teste 3: Swagger
    Write-Host "[TEST 3] Swagger UI..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "https://localhost:5001/swagger/index.html" -SkipCertificateCheck
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ PASSOU - Swagger está acessível" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "✗ FALHOU - Erro: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "URLs para testar:" -ForegroundColor White
    Write-Host "  • Swagger:      https://localhost:5001/swagger" -ForegroundColor Cyan
    Write-Host "  • Health Check: https://localhost:5001/health" -ForegroundColor Cyan
    Write-Host "  • API:          https://localhost:5001/api/contatos" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

# Ação: LOGS
elseif ($Action -eq "logs") {
    Write-Host "Monitorando logs da aplicação..." -ForegroundColor Yellow
    Write-Host ""
    
    if (-not (Test-ApiRunning)) {
        Write-Host "✗ Aplicação não está rodando!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✓ Aplicação está rodando" -ForegroundColor Green
    Write-Host ""
    Write-Host "Nota: Para ver logs em tempo real, execute a aplicação com:" -ForegroundColor Yellow
    Write-Host "  dotnet run" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Os logs aparecerão no terminal onde você executou o comando." -ForegroundColor Gray
}

Write-Host ""
