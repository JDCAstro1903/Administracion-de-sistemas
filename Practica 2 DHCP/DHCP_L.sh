#!/bin/bash

# Verificar si se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse como root o con sudo." >&2
    exit 1
fi

# Función para validar direcciones IP
validar_ip() {
    local ip=$1
    local regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
    if [[ $ip =~ $regex ]]; then
        IFS='.' read -r -a octets <<< "$ip"
        for octet in "${octets[@]}"; do
            if ((octet < 0 || octet > 255)); then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

# Máscaras de subred válidas
validar_subnet() {
    local subnet=$1
    local valid_subnets=(
        "255.0.0.0" "255.128.0.0" "255.192.0.0" "255.224.0.0"
        "255.240.0.0" "255.248.0.0" "255.252.0.0" "255.254.0.0"
        "255.255.0.0" "255.255.128.0" "255.255.192.0" "255.255.224.0"
        "255.255.240.0" "255.255.248.0" "255.255.252.0" "255.255.254.0"
        "255.255.255.0" "255.255.255.128" "255.255.255.192" "255.255.255.224"
        "255.255.255.240" "255.255.255.248" "255.255.255.252"
    )
    for valid in "${valid_subnets[@]}"; do
        if [[ "$subnet" == "$valid" ]]; then
            return 0
        fi
    done
    return 1
}

# Pedir datos al usuario
while true; do
    read -rp "Ingrese el rango de direcciones IP (ejemplo: 192.168.1.100-192.168.1.200): " scope
    IFS='-' read -r start_ip end_ip <<< "$scope"
    if validar_ip "$start_ip" && validar_ip "$end_ip"; then
        break
    fi
    echo "Rango inválido, intente nuevamente."
done

while true; do
    read -rp "Ingrese la puerta de enlace predeterminada: " gateway
    if validar_ip "$gateway"; then
        break
    fi
    echo "IP inválida, intente nuevamente."
done

while true; do
    read -rp "Ingrese la máscara de subred: " subnet
    if validar_subnet "$subnet"; then
        break
    fi
    echo "Máscara inválida, intente nuevamente."
done

while true; do
    read -rp "Ingrese el servidor DNS primario: " dns
    if validar_ip "$dns"; then
        break
    fi
    echo "IP inválida, intente nuevamente."
done

# Instalar el servidor DHCP
apt update && apt install -y isc-dhcp-server

# Configurar el archivo dhcpd.conf
cat <<EOF > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
authoritative;
subnet ${start_ip%.*}.0 netmask $subnet {
    range $start_ip $end_ip;
    option routers $gateway;
    option domain-name-servers $dns;
}
EOF

# Configurar interfaz de red
INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')
echo "INTERFACESv4=\"$INTERFACE\"" > /etc/default/isc-dhcp-server

# Reiniciar y habilitar el servicio DHCP
systemctl restart isc-dhcp-server
systemctl enable isc-dhcp-server

echo "Configuración completada en Ubuntu Server."
