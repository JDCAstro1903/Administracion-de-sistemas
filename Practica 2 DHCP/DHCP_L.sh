# Instalar servidor DHCP
sudo apt install -y isc-dhcp-server

# Solicitar datos al usuario
read -p "Ingrese la dirección IP estática: " ip_estatica
read -p "Ingrese el rango inicial de las direcciones IP: " rango1
read -p "Ingrese el rango final de las direcciones IP: " rango2
read -p "Ingrese la puerta de enlace: " gateway
read -p "Ingrese la máscara de red: " netmask
read -p "Ingrese el servidor DNS: " dns

# Extraer la red base de la IP
network_base=$(echo $ip_estatica | awk -F. '{print $1"."$2"."$3".0"}')

# Configurar IP estática
cat <<EOF | sudo tee /etc/netplan/99-dhcp-server.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s8:
      addresses:
        - $ip_estatica/24
      gateway4: $gateway
      nameservers:
        addresses: [$dns]
EOF

sudo chmod 600 /etc/netplan/99-dhcp-server.yaml
sudo netplan apply

# Configurar DHCP
sudo sed -i "s/^INTERFACESv4=.*/INTERFACESv4=\"enp0s8"/ /etc/default/isc-dhcp-server

# Crear archivo de configuración de DHCP
cat <<EOF | sudo tee /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;

subnet $network_base netmask $netmask {
  range $rango1 $rango2;
  option routers $gateway;
  options-domain-name-servers $dns;
}
EOF

sudo systemctl restart isc-dhcp-server
sudo systemctl enable isc-dhcp-server
sudo systemctl status isc-dhcp-server

echo "Configuracion completa"