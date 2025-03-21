sudo apt install vsftpd -y

sudo groupadd reprobados
sudo groupadd recursadores

sudo mkdir -p /srv/ftp/
sudo mkdir -p /srv/ftp/publico
sudo mkdir -p /srv/ftp/reprobados
sudo mkdir -p /srv/ftp/recursadores
sudo mkdir -p /srv/ftp/usuarios
sudo mkdir -p /srv/ftp/public/
sudo mkdir -p /srv/ftp/public/publico

echo "/srv/ftp/public/publico /srv/ftp/publico none bind 0 0" | sudo tee -a /etc/fstab

sudo chmod -R 777 /srv/ftp/publico
sudo chmod -R 755 /srv/ftp/usuarios
sudo chown -R :reprobados /srv/ftp/reprobados
sudo chmod -R 770 /srv/ftp/reprobados
sudo chown -R :recursadores /srv/ftp/recursadores
sudo chmod -R 770 /srv/ftp/recursadores

cat <<EOF | sudo tee /etc/vsftpd.conf
listen=YES
anonymous_enable=YES
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
anon_root=/srv/ftp/public

chroot_local_user=YES
allow_writeable_chroot=YES
user_sub_token=\$USER
local_root=/srv/ftp/usuarios/\$USER

pasv_min_port=30000
pasv_max_port=30100
EOF

sudo ufw allow 20,21/tcp
sudo ufw allow 30000:31000/tcp
sudo ufw enable

sudo systemctl restart vsftpd
sudo systemctl enable vsftpd


userValid() {
    local usuario=$1
    local error_msg="El nombre de usuario solo puede contener caracteres de la "a" hasta la "z" en minusculas y una longitud maxima de 10 "

    # Verificar que comience con una letra minúscula
    if [[ ! "$usuario" =~ ^[a-z] ]]; then
        echo "$error_msg"
        return 1
    fi

    # Verificar la longitud (máximo 20 caracteres)
    if [ ${#usuario} -gt 10 ]; then
        echo "$error_msg"
        return 1
    fi
    
    return 0
}


validarContra() {
    local contra=$1

    if [[ ! "$contra" =~ ^[A-Za-z][A-Za-z0-9_]{0,7}$ ]]; then
        echo "La contraseña debe comenzar con una letra, solo puede contener letras, números y guiones bajos, y debe tener un máximo de 8 caracteres."
        return 1
    fi
    if [[ "$password" =~ [[:space:]] ]]; then
        echo "Contraseña inválida. No se permiten espacios."
        return 1
    fi

    return 0
}


createUser() {
    local usuario=$1
    local grupo=$2

    if [[ -d "/srv/ftp/usuarios/$usuario" ]]; then
        echo "El usuario '$usuario' ya existe"
        return 1
    fi

    #Borra espacios si los hay al final del nombre

    # Crear directorios
    sudo mkdir -p /srv/ftp/usuarios/$usuario/{publico,"$grupo","$usuario"}
    sudo mkdir -p /srv/ftp/{publico,"$grupo"}

    # Crear usuario
    sudo useradd -m -d /srv/ftp/usuarios/$usuario/$usuario -s /bin/bash -G $grupo $usuario

    while true; do
        read -s -p "Escriba la contraseña para $usuario: " contra
        echo
        if ! validarContra "$contra"; then
            echo "Por favor, ingrese una contraseña válida."
            continue
        fi
        break
    done

    echo "$usuario:$contra" | sudo chpasswd

    # Asignar permisos
    sudo chown -R $usuario:$grupo /srv/ftp/usuarios/$usuario
    sudo chmod -R 700 /srv/ftp/usuarios/$usuario/$usuario
    sudo chmod -R 770 /srv/ftp/usuarios/$usuario/$grupo

    # Montar carpetas
    sudo mount --bind /srv/ftp/$grupo /srv/ftp/usuarios/$usuario/$grupo
    echo "/srv/ftp/$grupo /srv/ftp/usuarios/$usuario/$grupo none bind 0 0" | sudo tee -a /etc/fstab

    sudo mount --bind /srv/ftp/publico /srv/ftp/usuarios/$usuario/publico
    echo "/srv/ftp/publico /srv/ftp/usuarios/$usuario/publico none bind 0 0" | sudo tee -a /etc/fstab
}

while true; do
    read -p "¿Desea agregar un usuario? (s/n): " respuesta
    if [[ "$respuesta" != "s" ]]; then
        break
    fi

    while true; do
        read -p "Escriba el nombre del usuario: " nombreUsuario

        if ! userValid "$nombreUsuario"; then
            echo "Por favor, ingrese un nombre de usuario válido."
            continue
        fi
        break
    done

    while true; do
        read -p "Escriba el grupo al que pertenecerá el usuario $nombreUsuario [reprobados/recursadores]: " nombreGrupo
        if [[ "$nombreGrupo" == "reprobados" || "$nombreGrupo" == "recursadores" ]]; then
            break
        fi
        echo "El grupo ingresado no es válido. Por favor, ingrese 'reprobados' o 'recursadores'."
    done

    createUser "$nombreUsuario" "$nombreGrupo"
done