#!/bin/bash

# Actualizar repositorios e instalar Bind9
sudo apt update && sudo apt install -y bind9

# Configurar la IP estática en la interfaz enp0s3
cat <<EOF | sudo tee /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    enp0s8:
      addresses:
        - 10.0.0.10/24
      gateway4: 10.0.0.1
      nameservers:
        addresses:
          - 10.0.0.10
EOF

sudo netplan apply

# Configurar Bind9: zona primaria para reprobados.com
sudo bash -c "cat > /etc/bind/reprobados.com" <<EOF
zone "reprobados.com" {
    type master;
    file "/etc/bind/db.reprobados.com";
};
EOF

# Crear archivo de zona para reprobados.com
sudo bash -c "cat > /etc/bind/db.reprobados.com" <<EOF
\$TTL    604800
@       IN      SOA     ns.reprobados.com. admin.reprobados.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.reprobados.com.
ns      IN      A       10.0.0.10
@       IN      A       10.0.0.10
www     IN      A       10.0.0.10
EOF

# Configurar permisos correctos para la zona
sudo chown root:bind /etc/bind/db.reprobados.com
sudo chmod 644 /etc/bind/db.reprobados.com

# Configurar opciones de Bind9
sudo bash -c "cat > /etc/bind/named.conf.options" <<EOF
options {
    directory "/var/cache/bind";
    listen-on { 10.0.0.10; };
    allow-query { any; };
    recursion no;
    forwarders {};
    dnssec-validation no;
};
EOF

# Verificar configuración de Bind9
sudo named-checkconf
sudo named-checkzone reprobados.com /etc/bind/db.reprobados.com

# Reiniciar servicio DNS
sudo systemctl restart bind9
sudo systemctl enable bind9

# Actualizar resolv.conf para usar el propio DNS
sudo bash -c "echo 'nameserver 10.0.0.10' > /etc/resolv.conf"

# Verificar la configuración
echo "Verificando configuración de DNS..."
nslookup www.reprobados.com
nslookup reprobados.com
