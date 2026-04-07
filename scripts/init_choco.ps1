# Script para instalar o Chocolatey
$ErrorActionPreference = 'Stop'

try {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Chocolatey já está instalado." -ForegroundColor Cyan
    } else {
        Write-Host "Instalando Chocolatey..." -ForegroundColor Yellow
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "Chocolatey instalado com sucesso." -ForegroundColor Green
    }
} catch {
    Write-Error "Falha ao instalar o Chocolatey: $_"
    exit 1
}
