# Script de configurações do sistema
$ErrorActionPreference = 'Continue'

Write-Host "Configurando sistema..." -ForegroundColor Cyan

# 1. Ponto de Restauração
try {
    Write-Host "[1/4] Configurando ponto de restauração..." -ForegroundColor Yellow
    Enable-ComputerRestore -Drive "C:" -ErrorAction SilentlyContinue
    vssadmin resize shadowstorage /on=C: /for=C: /maxsize=8% 
} catch {
    Write-Warning "Não foi possível configurar o ponto de restauração."
}

# 2. Descoberta de Rede e Firewall
Write-Host "[2/4] Ativando descoberta de rede..." -ForegroundColor Yellow
netsh advfirewall firewall set rule group="Descoberta de Rede" new enable=yes
netsh advfirewall firewall set rule group="Compartilhamento de Arquivo e Impressora" new enable=yes

# 3. Habilitar Ping (ICMP)
Write-Host "[3/4] Habilitando Ping..." -ForegroundColor Yellow
netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=allow 2>$null

# 4. Informações e Renomeação
$computer = Get-CimInstance Win32_ComputerSystem
Write-Host "`nInformações atuais do sistema:" -ForegroundColor Cyan
Write-Host "Nome: $($computer.Name)"
Write-Host "Workgroup: $($computer.Workgroup)"
$mac = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1 -ExpandProperty MacAddress
Write-Host "MAC Principal: $mac"

$choice = Read-Host "`nDeseja alterar o nome do computador agora? (S/N)"
if ($choice -eq 'S' -or $choice -eq 's') {
    $newName = Read-Host "Digite o novo Nome do Computador"
    $newWorkgroup = Read-Host "Digite o novo Grupo de Trabalho (deixe em branco para manter)"
    
    if ($newName) {
       Rename-Computer -NewName $newName -Force
       Write-Host "Nome alterado para $newName. Reinicie após terminar o script." -ForegroundColor Green
    }
    
    if ($newWorkgroup) {
        Add-Computer -WorkGroupName $newWorkgroup
        Write-Host "Workgroup alterado para $newWorkgroup." -ForegroundColor Green
    }
}

Write-Host "`nConfigurações de sistema concluídas." -ForegroundColor Cyan
