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

# Solicitar y validar el rango de IPs
do {
    $Scope = Read-Host "Ingrese el rango de direcciones IP (ejemplo: 192.168.1.100-192.168.1.200)"
    $rango = $Scope -split '-'
} while ($rango.Count -ne 2 -or -not (Validar-IP $rango[0]) -or -not (Validar-IP $rango[1]))

# Solicitar y validar la puerta de enlace
do {
    $Gateway = Read-Host "Ingrese la puerta de enlace predeterminada (ejemplo: 192.168.1.1)"
} while (-not (Validar-IP $Gateway))

# Solicitar y validar la máscara de subred
do {
    $Subnet = Read-Host "Ingrese la máscara de subred (ejemplo: 255.255.255.0)"
} while (-not (Validar-Subnet $Subnet))

# Solicitar y validar el servidor DNS
do {
    $Dns = Read-Host "Ingrese el servidor DNS primario (ejemplo: 8.8.8.8)"
} while (-not (Validar-IP $Dns))

# Determinar la dirección de red
function Obtener-DireccionRed {
    param ($ip, $subnet)
    $ipBytes = $ip -split '\.' | ForEach-Object { [int]$_ }
    $subnetBytes = $subnet -split '\.' | ForEach-Object { [int]$_ }
    $red = @()
    for ($i = 0; $i -lt 4; $i++) {
        $red += ($ipBytes[$i] -band $subnetBytes[$i])
    }
    return $red -join "."
}

$NetworkID = Obtener-DireccionRed -ip $rango[0] -subnet $Subnet
Write-Host "Dirección de red calculada: $NetworkID"

# Instalar el rol DHCP si no está instalado
$DHCPFeature = Get-WindowsFeature -Name 'DHCP'
if (-not $DHCPFeature.Installed) {
    Write-Host "Instalando el servicio DHCP..." -ForegroundColor Yellow
    Install-WindowsFeature -Name 'DHCP' -IncludeManagementTools
} else {
    Write-Host "El servicio DHCP ya está instalado." -ForegroundColor Green
}

# Iniciar y habilitar el servicio DHCP
Write-Host "Habilitando y arrancando el servicio DHCP..." -ForegroundColor Yellow
Set-Service -Name 'DHCPServer' -StartupType Automatic
Start-Service 'DHCPServer'

# Agregar la autorización DHCP (solo si está en un dominio)
#if ((Get-WmiObject Win32_ComputerSystem).PartOfDomain) {
#    Write-Host "Autorizando el servidor DHCP en el dominio..." -ForegroundColor Yellow
#    Add-DhcpServerInDC
#}

# Crear el ámbito DHCP
Write-Host "Creando el ámbito DHCP..." -ForegroundColor Yellow
Add-DhcpServerv4Scope -Name "MiRed" -StartRange $rango[0] -EndRange $rango[1] -SubnetMask $Subnet -State Active

# Configurar opciones de DHCP
Write-Host "Configurando opciones DHCP..." -ForegroundColor Yellow
Set-DhcpServerv4OptionValue -ScopeId $NetworkID -OptionId 3 -Value $Gateway
Set-DhcpServerv4OptionValue -ScopeId $NetworkID -OptionId 6 -Value $Dns

Write-Host "Configuración completada con éxito en Windows Server." -ForegroundColor Green
