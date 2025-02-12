#Instalar servicio DNS
Write-Host "Instalando el servicio DNS..." -ForegroundColor Cyan
Install-WindowsFeature -Name DNS

#Configurar la IP estatica y el DNS en la interfaz
Write-Host "Configurando la IP en la interfaz " -ForegroundColor Cyan
New-NetIPAddress -InterfaceAlias "Ethernet 2" -IPAddress 10.0.0.20 -PrefixLength 24

#Crear la zona primaria
Write-Host "Creando la zona primaria para el dominio " -Foreground Cyan
Add-DnsServerPrimaryZone -Name "reprobados.com" -ZoneFile "reprobados.com.dns" -DynamicUpdate None

#Agregar dominios
Write-Host "Agregando registros..." -Foreground Cyan
Add-DnsServerResourceRecordA -ZoneName "reprobados.com" -Name "@" -IPv4Address 10.0.0.20
Add-DnsServerResourceRecordA -ZoneName "reprobados.com" -Name "www" -IPv4Address 10.0.0.20

#Firewall
Write-Host "Configurando firewall..." -Foreground Cyan
New-NetFirewallRule -DisplayName "Allow ICMPv4" -Protocol ICMPv4 -Direction Inbound -Action Allow

#direccion del DNS
Write-Host "Configurando DNS" -Foreground Cyan
Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddress 10.0.0.20

#Reiniciar el servicio
Write-Host "Reiniciando servicio DNS..." -Foreground Cyan
Restart-Service -Name DNS

#Verificar la configuración
Write-Host "Verificando la configuración..." -Foreground Cyan
nslookup www.reprobados.com 127.0.0.1
nslookup reprobados.com 127.0.0.1
