# Verificar si el módulo OpenSSH está disponible
if (-not (Get-WindowsFeature -Name OpenSSH-Server).Installed) {
    Write-Output "Instalando OpenSSH Server..."
    Add-WindowsFeature -Name OpenSSH-Server
}
#Cambiar la direccion IP
New-NetIPAddress -InterfaceAlias "Ethernet 2" -IPAddress 192.168.1.160 -PrefixLength 24 -DefaultGateway 192.168.1.1

# Iniciar y habilitar el servicio SSH
Write-Output "Iniciando y habilitando el servicio SSH..."
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic

# Configurar firewall para permitir SSH
Write-Output "Configurando firewall para permitir SSH..."
New-NetFirewallRule -Name "OpenSSH" -DisplayName "OpenSSH Server (sshd)" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

Write-Output "Configuración de SSH en Windows completada. Puedes conectarte con:"
Write-Output "  ssh daniel@192.168.1.160"
