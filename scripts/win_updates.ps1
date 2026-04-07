# Script para atualizar o Windows
$ErrorActionPreference = 'Continue'

Write-Host "Verificando Atualizações do Windows..." -ForegroundColor Cyan

# Tenta usar o módulo PSWindowsUpdate
$module = Get-Module -ListAvailable PSWindowsUpdate

if (-not $module) {
    Write-Host "Instalando módulo de atualização (PSWindowsUpdate)..." -ForegroundColor Yellow
    try {
        Install-Module -Name PSWindowsUpdate -Force -SkipPublisherCheck -Scope CurrentUser -Confirm:$false
        Import-Module PSWindowsUpdate
    } catch {
        Write-Warning "Falha ao instalar módulo PSWindowsUpdate via PowerShell Gallery."
        Write-Host "Tentando via Chocolatey..." -ForegroundColor Yellow
        choco install pswindowsupdate -y
        Import-Module PSWindowsUpdate -ErrorAction SilentlyContinue
    }
}

if (Get-Module -ListAvailable PSWindowsUpdate) {
    Write-Host "Buscando e instalando atualizações..." -ForegroundColor Yellow
    # Aceita tudo e instala
    Get-WindowsUpdate -Install -AcceptAll -IgnoreReboot
    Write-Host "Processo de atualização finalizado." -ForegroundColor Green
} else {
    Write-Error "Não foi possível carregar o módulo de atualizações."
}
