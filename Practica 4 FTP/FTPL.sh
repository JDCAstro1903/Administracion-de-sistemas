Servidorftp (){
#!/bin/bash

# Archivo de configuración de vsftpd
CONFIG_FILE="/etc/vsftpd.conf"

# Definimos los nombres de los grupos de usuarios FTP
GROUP1="reprobados"
GROUP2="recursadores"
SHARED_GROUP="ftp_compartida"

# Definimos las rutas de las carpetas grupales y compartida
GROUP1_DIR="/srv/ftp_reprobados"
GROUP2_DIR="/srv/ftp_recursadores"
SHARED_DIR="/srv/ftp_compartida"

# Actualiza los repositorios e instala vsftpd si no está instalado
echo "=== 1. ACTUALIZANDO E INSTALANDO VSFTPD ==="
sudo apt update && sudo apt install -y vsftpd

# Crear los grupos si no existen
echo "=== 2. CREANDO GRUPOS ==="
sudo groupadd $GROUP1 2>/dev/null || echo "Grupo $GROUP1 ya existe"
sudo groupadd $GROUP2 2>/dev/null || echo "Grupo $GROUP2 ya existe"

# Crear las carpetas donde los grupos guardarán sus archivos
echo "=== 3. CREANDO CARPETAS GRUPALES ==="
sudo mkdir -p $GROUP1_DIR $GROUP2_DIR $SHARED_DIR

# Configurar permisos de las carpetas grupales
sudo chown :$GROUP1 $GROUP1_DIR   # Asigna la carpeta al grupo "reprobados"
sudo chmod 770 $GROUP1_DIR        # Permite acceso total solo a los miembros del grupo

sudo chown :$GROUP2 $GROUP2_DIR   # Asigna la carpeta al grupo "recursadores"
sudo chmod 770 $GROUP2_DIR        # Permite acceso total solo a los miembros del grupo

# Configurar la carpeta compartida
sudo chown :$GROUP1 $SHARED_DIR   # Propietario: Grupo "reprobados"
sudo chgrp $GROUP2 $SHARED_DIR    # Grupo secundario: "recursadores"
sudo chmod 775 $SHARED_DIR        # Permite lectura y escritura a ambos grupos

# Preguntar cuántos usuarios deseas crear
echo "¿Cuántos usuarios FTP deseas crear?"
while true; do
    read NUM_USERS
    if [[ "$NUM_USERS" =~ ^[0-9]+$ ]]; then
        break  # Si es un número válido, salir del bucle
    else
        echo "Error: Debes ingresar un número válido. Intenta nuevamente:"
    fi
done

# Bucle para crear múltiples usuarios
for ((i=1; i<=NUM_USERS; i++))
do
    echo "=== Creando usuario #$i ==="
    
    # Pedir nombre de usuario
    echo "Ingresa el nombre para el usuario FTP #$i:"
    read FTP_USER
    
    # Pedir contraseña de forma oculta
    echo "Ingresa la contraseña para $FTP_USER:"
    read -s FTP_PASSWORD

    # Elegir el grupo del usuario
    while true; do
        echo "Selecciona el grupo para $FTP_USER: ($GROUP1/$GROUP2)"
        read FTP_GROUP

        # Validar que el grupo sea correcto
        if [[ "$FTP_GROUP" == "$GROUP1" || "$FTP_GROUP" == "$GROUP2" ]]; then
            break  # Si el grupo es válido, salir del bucle
        else
            echo "Error: Grupo inválido. Debes seleccionar entre $GROUP1 o $GROUP2. Intenta nuevamente:"
        fi
    done

    # Crear el usuario sin acceso SSH (solo FTP)
    sudo adduser --disabled-password --gecos "" $FTP_USER
    echo "$FTP_USER:$FTP_PASSWORD" | sudo chpasswd

    # Asignar el usuario a su grupo seleccionado
    sudo usermod -aG $FTP_GROUP $FTP_USER

    # Crear la carpeta personal del usuario dentro de /home/usuario/
    FTP_PERSONAL="/home/$FTP_USER/ftp_personal"
    sudo mkdir -p $FTP_PERSONAL
    sudo chown $FTP_USER:$FTP_USER $FTP_PERSONAL
    sudo chmod 750 $FTP_PERSONAL  # Solo el usuario y root pueden acceder

    # Definir el directorio principal que será visible para el usuario
    if [[ "$FTP_GROUP" == "$GROUP1" ]]; then
        USER_DIR=$GROUP1_DIR
    else
        USER_DIR=$GROUP2_DIR
    fi

    # Crear un enlace simbólico a la carpeta del grupo en el directorio personal del usuario
    sudo ln -s $USER_DIR /home/$FTP_USER/$FTP_GROUP
    # Crear enlace simbólico para la carpeta compartida
    sudo ln -s $SHARED_DIR /home/$FTP_USER/$SHARED_GROUP

    echo "Usuario $FTP_USER creado con éxito en grupo $FTP_GROUP."
done

# Configurar vsftpd para acceso anónimo
echo "=== 5. CONFIGURANDO VSFTPD PARA ACCESO ANONIMO ==="
sudo cp $CONFIG_FILE ${CONFIG_FILE}.bak  # Crea un respaldo del archivo de configuración original

# Escribe la configuración personalizada en el archivo de vsftpd para habilitar acceso anónimo
sudo bash -c "cat > $CONFIG_FILE" <<EOL
listen=YES                   # Activa el modo standalone (servidor independiente)
anonymous_enable=YES          # Habilita el acceso anónimo
local_enable=NO               # Desactiva usuarios locales
write_enable=YES              # Permite que los usuarios escriban archivos (opcional, puedes desactivar si solo quieres descarga)
anon_root=/srv/ftp_reprobados  # Directorio principal para usuarios anónimos (puede ser uno de los grupos)
anon_umask=022                # Permite archivos con permisos 644 para archivos y 755 para directorios
anon_max_rate=102400          # Límite de velocidad de descarga (opcional)
pasv_enable=YES               # Activa modo pasivo para evitar bloqueos por firewall
pasv_min_port=40000           # Puerto mínimo para conexiones pasivas
pasv_max_port=40100           # Puerto máximo para conexiones pasivas
hide_ids=YES                  # Oculta los IDs de usuarios y grupos
EOL

# Reiniciar el servicio vsftpd para aplicar cambios
echo "=== 6. REINICIANDO VSFTPD ==="
sudo systemctl restart vsftpd
sudo systemctl enable vsftpd  # Habilitar el servicio para que inicie con el sistema

echo "=== SERVIDOR FTP CON ACCESO ANONIMO Y USUARIOS CONFIGURADO CORRECTAMENTE ==="
}