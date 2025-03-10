userValid() {
    local usuario=$1
    local error_msg="El nombre de usuario debe comenzar con una letra minúscula o guion bajo, además solo puede contener letras minúsculas, números, guiones bajos y guiones, no puede terminar con un guion y no puede tener más de 20 caracteres, los espacios al comienzo y al final serán eliminados."

    # Verificar que comience con una letra minúscula o guion bajo
    if [[ ! "$usuario" =~ ^[a-z_] ]]; then
        echo "$error_msg"
        return 1
    fi

    # Verificar que solo contenga caracteres permitidos
    if [[ ! "$usuario" =~ ^[a-z0-9_-]+$ ]]; then
        echo "$error_msg"
        return 1
    fi

    # Verificar que no termine con un guion
    if [[ "$usuario" =~ -$ ]]; then
        echo "$error_msg"
        return 1
    fi

    # Verificar la longitud (máximo 20 caracteres)
    if [ ${#usuario} -gt 20 ]; then
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

    echo "Si ingresaste espacios al final del nombre del usuario serán eliminados."

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

    echo "Si ingresaste espacios al final de la contraseña serán eliminados."

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
    read -p "¿Desea agregar un usuario? (y/n): " respuesta
    if [[ "$respuesta" != "y" ]]; then
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