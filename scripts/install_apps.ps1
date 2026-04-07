# Script para instalar programas via Chocolatey
param (
    [string[]]$Packages
)

if ($null -eq $Packages -or $Packages.Count -eq 0) {
    Write-Host "Nenhum pacote especificado para instalação." -ForegroundColor Gray
    return
}

Write-Host "Iniciando a instalação dos programas..." -ForegroundColor Cyan

foreach ($pkg in $Packages) {
    Write-Host "Instalando: $pkg..." -ForegroundColor Yellow
    # --force removido para evitar reinstalações desnecessárias, mas -y mantido para silêncio
    choco install $pkg -y --limit-output --no-progress
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Sucesso: $pkg" -ForegroundColor Green
    } else {
        Write-Warning "Erro ao instalar: $pkg (Código: $LASTEXITCODE)"
    }
}

Write-Host "Processo de instalação concluído." -ForegroundColor Cyan
