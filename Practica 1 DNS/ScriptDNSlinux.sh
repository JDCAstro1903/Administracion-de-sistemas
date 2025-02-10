#!/bin/bash
# Script para configurar un Servidor DNS en Ubuntu Server con Bind9

# 1. Instalar Bind9
apt update
apt install -y bind9

# 2. Configurar la zona de búsqueda directa
echo '
zone "reprobados.com" {
    type master;
    file "/etc/bind/db.reprobados.com";
};' >> /etc/bind/named.conf.local

# 3. Configurar la zona inversa
echo '
zone "0.0.10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10.0.0";
};' >> /etc/bind/named.conf.local

# 4. Crear el archivo de zona directa
cat <<EOT > /etc/bind/db.reprobados.com
\$TTL 604800
@       IN      SOA     reprobados.com. admin.reprobados.com. (
                            2         ; Serial
                            604800    ; Refresh
                            86400     ; Retry
                            2419200   ; Expire
                            604800 )  ; Negative Cache TTL
;
@       IN      NS      ns.reprobados.com.
ns      IN      A       10.0.0.10
www     IN      A       10.0.0.10
EOT

# 5. Crear el archivo de zona inversa
cat <<EOT > /etc/bind/db.10.0.0
\$TTL 604800
@       IN      SOA     reprobados.com. admin.reprobados.com. (
                            2         ; Serial
                            604800    ; Refresh
                            86400     ; Retry
                            2419200   ; Expire
                            604800 )  ; Negative Cache TTL
;
@       IN      NS      ns.reprobados.com.
10      IN      PTR     ns.reprobados.com.
10      IN      PTR     www.reprobados.com.
EOT

# 6. Reiniciar Bind9
systemctl restart bind9
systemctl enable bind9

# 7. Verificar el estado del servicio
systemctl status bind9

# 8. Verificar la configuración
nslookup www.reprobados.com 
nslookup 10.0.0.10 
