Write-Host "Iniciando configuración del servidor DHCP en Windows Server..." -ForegroundColor Cyan

# Función para validar direcciones IP
function Validar-IP {
    param ($ip)
    return $ip -match '^(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)$'
}

# Función para validar máscaras de subred
function Validar-Subnet {
    param ($subnet)
    $subnetsValidas = @("255.0.0.0", "255.128.0.0", "255.192.0.0", "255.224.0.0", "255.240.0.0", "255.248.0.0", "255.252.0.0", "255.254.0.0", "255.255.0.0", "255.255.128.0", "255.255.192.0", "255.255.224.0", "255.255.240.0", "255.255.248.0", "255.255.252.0", "255.255.254.0", "255.255.255.0", "255.255.255.128", "255.255.255.192", "255.255.255.224", "255.255.255.240", "255.255.255.248", "255.255.255.252")
    return $subnetsValidas -contains $subnet
}

# Solicitar dirección IP
do {
    $IpEstatica = Read-Host "Ingresa una dirección IP Estática (Ej 10.0.0.10)"
} while (-not (Validar-IP $IpEstatica))

# Solicitar rango de direcciones IP
do {
    $Scope = Read-Host "Ingrese el rango de direcciones IP (Ejemplo: 192.168.1.100 - 192.168.1.200)" -ForeGroundColor Cyan
    $rango = $Scope -split '-'
} while ($rango.Count -ne 2 -or -not (Validar-IP $rango[0]) -or -not (Validar-IP $rango[1]))

# Solicitar Gateway
do {
    $Gateway = Read-Host "Ingrese la puerta de enlace predeterminada (Ejemplo: 192.168.1.1)" -ForeGroundColor Cyan
} while (-not (Validar-IP $Gateway))

# Solicitar máscara de subred
do {
    $Subnet = Read-Host "Ingrese la máscara de la subred (Ejemplo: 255.255.255.0)" -ForeGroundColor Cyan
} while (-not (Validar-Subnet $Subnet))

# Solicitar DNS
do {
    $DNS = Read-Host "Ingrese el servidor DNS (Ejemplo: 8.8.8.8)" -ForeGroundColor Cyan
} while (-not (Validar-IP $DNS))

# Interfaz de red
$int = "Ethernet 2"

# Asignar IP al servidor
New-NetIPAddress -IpAddress $IpEstatica -PrefixLength 24 -DefaultGateway $Gateway -InterfaceAlias $int

# Instalar DHCP
Write-Host "Instalando el servicio DHCP" -ForeGroundColor Cyan
Install-WindowsFeature -Name 'DHCP' -IncludeManagementTools
Restart-Service DHCPServer

# Configurar DHCP
Write-Host "Configurando DHCP" -ForeGroundColor Cyan
Add-DhcpServerV4Scope -Name "MiRed" -StartRange $rango[0] -EndRange $rango[1] -SubnetMask $Subnet -State Active
Start-Service DHCPServer

# Configurar gateway y DNS
Set-DhcpServerV4OptionValue -ScopeId $rango[0] -OptionId 3 -Value $Gateway
Set-DhcpServerV4OptionValue -ScopeId $rango[0] -OptionId 6 -Value $DNS

New-NetFirewallRule -name "Allow-Ping" -DisplayName "Permitir Ping" -Protocol ICMPv4 -Direction Inbound -Action Allow

Write-Host "Configuración completada con éxito en Windows Server." -ForegroundColor Green
