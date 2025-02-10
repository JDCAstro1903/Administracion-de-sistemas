# 1. Instalar el servicio DNS
Install-WindowsFeature -Name DNS -IncludeManagementTools

# 2. Configurar la IP estática y el DNS en la interfaz "Ethernet"
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.0.0.20 -PrefixLength 24 -DefaultGateway 10.0.0.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1

# 3. Crear la zona primaria para el dominio "reprobados.com"
Add-DnsServerPrimaryZone -Name "reprobados.com" -ZoneType Primary -DynamicUpdate Secure

# 4. Crear la zona inversa (para la red 10.0.0.x)
Add-DnsServerPrimaryZone -NetworkID "10.0.0" -ZoneFile "0.0.10.in-addr.arpa.dns" -DynamicUpdate Secure

# 5. Agregar registros A (host) para el dominio y un subdominio
Add-DnsServerResourceRecordA -ZoneName "reprobados.com" -Name "ns" -IPv4Address 10.0.0.20
Add-DnsServerResourceRecordA -ZoneName "reprobados.com" -Name "www" -IPv4Address 10.0.0.20

# 6. Agregar un registro NS (servidor de nombres)
Add-DnsServerResourceRecordNS -ZoneName "reprobados.com" -Name "@" -NameServer "ns.reprobados.com"

# 7. Agregar registros PTR en la zona inversa
Add-DnsServerResourceRecordPTR -ZoneName "0.0.10.in-addr.arpa" -Name "20" -PtrDomainName "ns.reprobados.com"
Add-DnsServerResourceRecordPTR -ZoneName "0.0.10.in-addr.arpa" -Name "20" -PtrDomainName "www.reprobados.com"

# 8. Reiniciar el servicio DNS
Restart-Service -Name DNS

# 9. Verificar la configuración
nslookup www.reprobados.com 127.0.0.1
nslookup 10.0.0.20 127.0.0.1
