#!/bin/bash

# Variables
FTP_ROOT="/srv/ftp"
GENERAL_FOLDER="$FTP_ROOT/general"
REPROBADOS_FOLDER="$FTP_ROOT/reprobados"
RECURSADORES_FOLDER="$FTP_ROOT/recursadores"
VSFTPD_CONF="/etc/vsftpd.conf"

# Instalación de vsftpd
echo "Instalando vsftpd..."
sudo apt update -y
sudo apt install -y vsftpd

# Configuración de vsftpd
echo " Configurando vsftpd..."
sudo cp $VSFTPD_CONF ${VSFTPD_CONF}.bak  # Backup
sudo bash -c "cat > $VSFTPD_CONF" <<EOF
listen=YES
anonymous_enable=YES
local_enable=YES
write_enable=YES
anon_root=$FTP_ROOT
anon_umask=022
local_umask=022
chroot_local_user=YES
allow_writeable_chroot=YES
user_sub_token=\$USER
local_root=/srv/ftp/\$USER
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40100
EOF

# Crear directorios
echo "Creando estructura de carpetas..."
sudo mkdir -p $GENERAL_FOLDER $REPROBADOS_FOLDER $RECURSADORES_FOLDER
sudo chmod 777 $GENERAL_FOLDER $REPROBADOS_FOLDER $RECURSADORES_FOLDER

# Crear grupos
echo "Creando grupos de usuarios..."
sudo groupadd reprobados
sudo groupadd recursadores

# Agregar usuarios
echo " Agregando usuarios..."
while true; do
    read -p "Ingrese el nombre de usuario (o 'fin' para terminar): " USERNAME
    [[ "$USERNAME" == "fin" ]] && break

    while true; do
        read -p "¿Grupo? (1: Reprobados, 2: Recursadores): " GROUP_CHOICE
        case $GROUP_CHOICE in
            1) GROUP="reprobados"; break ;;
            2) GROUP="recursadores"; break ;;
            *) echo " Opción inválida, intente de nuevo." ;;
        esac
    done

    # Crear usuario
    sudo useradd -m -d /srv/ftp/$USERNAME -s /usr/sbin/nologin -G $GROUP $USERNAME
    sudo passwd $USERNAME

    # Permisos
    USER_FOLDER="/srv/ftp/$USERNAME"
    sudo mkdir -p $USER_FOLDER
    sudo chown $USERNAME:$USERNAME $USER_FOLDER
    sudo chmod 700 $USER_FOLDER

    # Acceso a la carpeta general y de grupo
    sudo usermod -aG $GROUP $USERNAME
    sudo ln -s $GENERAL_FOLDER $USER_FOLDER/general
    sudo ln -s $(eval echo \$$GROUP"_FOLDER") $USER_FOLDER/grupo

    echo " Usuario $USERNAME agregado al grupo $GROUP con acceso a /general y /$GROUP"
done

# Reiniciar vsftpd
echo " Reiniciando vsftpd..."
sudo systemctl restart vsftpd

echo " Configuración completa. Usuarios pueden conectarse vía FTP."
