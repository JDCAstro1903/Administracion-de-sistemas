# Variables globales
$Global:FTP_ROOT = "C:\FTP"
$Global:FTP_SITE = "FTP_Site"
$Global:GROUP1 = "Reprobados"
$Global:GROUP2 = "Recursadores"
$Global:SHARED_GROUP = "FTP_Compartida"

function Show-MainMenu {
    Clear-Host
    Write-Host "=== Administración del Servidor FTP ===" -ForegroundColor Cyan
    Write-Host "1. Configurar Servidor FTP"
    Write-Host "2. Gestionar Usuarios"
    Write-Host "3. Salir"
    Write-Host "===================================" -ForegroundColor Cyan
    
    $choice = Read-Host "`nSeleccione una opción"
    return $choice
}

function Show-UserMenu {
    Clear-Host
    Write-Host "=== Gestión de Usuarios FTP ===" -ForegroundColor Cyan
    Write-Host "1. Crear nuevo usuario"
    Write-Host "2. Listar usuarios existentes"
    Write-Host "3. Volver al menú principal"
    Write-Host "============================" -ForegroundColor Cyan
    
    $choice = Read-Host "`nSeleccione una opción"
    return $choice
}

function Initialize-FTPServer {
    try {
        Write-Host "`nConfigurando servidor FTP..." -ForegroundColor Cyan
        
        # Instalar IIS y FTP
        Install-WindowsFeature -Name Web-Server, Web-FTP-Server -IncludeManagementTools
        
        # Crear carpeta para acceso anónimo
        $anonymousDir = "$FTP_ROOT\General"
        New-Item -ItemType Directory -Path $anonymousDir -Force
        
        # Configurar permisos para anonymous
        icacls "$anonymousDir" /grant "IUSR:(OI)(CI)RX" /grant "IIS_IUSRS:(OI)(CI)RX"
        
        # Crear estructura de carpetas
        @("$FTP_ROOT", "$FTP_ROOT\$GROUP1", "$FTP_ROOT\$GROUP2", "$FTP_ROOT\Compartida") | 
        ForEach-Object { New-Item -ItemType Directory -Path $_ -Force }
        
        # Crear grupos
        @($GROUP1, $GROUP2) | ForEach-Object {
            if (-not (Get-LocalGroup -Name $_ -ErrorAction SilentlyContinue)) {
                New-LocalGroup -Name $_
            }
        }
        
        # Configurar permisos
        icacls "$FTP_ROOT\$GROUP1" /grant "$GROUP1 :(OI)(CI)F"
        icacls "$FTP_ROOT\$GROUP2" /grant "$GROUP2 :(OI)(CI)F"
        icacls "$FTP_ROOT\Compartida" /grant "$GROUP1 :(OI)(CI)M" /grant "$GROUP2 :(OI)(CI)M"
        
        # Configurar Firewall
        New-NetFirewallRule -DisplayName "FTP Server" -Direction Inbound -Protocol TCP -LocalPort 21 -Action Allow
        New-NetFirewallRule -DisplayName "FTP Passive" -Direction Inbound -Protocol TCP -LocalPort 40000-40100 -Action Allow
        
        # Configurar sitio FTP
        New-WebFtpSite -Name $FTP_SITE -Port 21 -PhysicalPath $FTP_ROOT -Force
        
        # Configurar SSL
        Set-WebConfigurationProperty -filter "system.applicationHost/sites/site[@name='$FTP_SITE']/ftpServer/security/ssl" -name "controlChannelPolicy" -value "SslAllow"
        Set-WebConfigurationProperty -filter "system.applicationHost/sites/site[@name='$FTP_SITE']/ftpServer/security/ssl" -name "dataChannelPolicy" -value "SslAllow"
        
        # Habilitar autenticación anónima y básica
        Set-WebConfigurationProperty -filter "/system.applicationHost/sites/site[@name='$FTP_SITE']/ftpServer/security/authentication/basicAuthentication" -name "enabled" -value "true"
        Set-WebConfigurationProperty -filter "/system.applicationHost/sites/site[@name='$FTP_SITE']/ftpServer/security/authentication/anonymousAuthentication" -name "enabled" -value "true"
        
        # Configurar autorización anónima
        Add-WebConfigurationProperty -Filter "/system.ftpServer/security/authorization" -PSPath "IIS:\" -Location "FTP_Site" -Name "." -Value @{
            accessType="Allow"
            roles=""
            permissions="Read"
            users="*"
        }
        
        # Configurar aislamiento de usuarios
        Set-WebConfigurationProperty -filter "/system.applicationHost/sites/site[@name='$FTP_SITE']/ftpServer/userIsolation" -name "mode" -value "StartInUsersDirectory"
        
        # Reiniciar servicios para aplicar cambios
        Restart-Service ftpsvc -Force
        Restart-Service W3SVC -Force
        
        Write-Host "Servidor FTP configurado exitosamente" -ForegroundColor Green
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
    pause
}

function Test-Username {
    param([string]$username)
    
    if ($username.Length -gt 14) {
        Write-Host "El nombre de usuario no puede exceder 14 caracteres" -ForegroundColor Red
        return $false
    }
    
    if ($username -notmatch '^[a-zA-Z]+$') {
        Write-Host "El nombre de usuario solo puede contener letras" -ForegroundColor Red
        return $false
    }
    
    return $true
}

function Test-Password {
    param([string]$password)
    
    # Validar longitud
    if ($password.Length -lt 8 -or $password.Length -gt 14) {
        Write-Host "La contraseña debe tener entre 8 y 14 caracteres" -ForegroundColor Red
        return $false
    }
    
    # Validar mayúscula
    if ($password -notmatch '[A-Z]') {
        Write-Host "La contraseña debe contener al menos una mayúscula" -ForegroundColor Red
        return $false
    }
    
    # Validar número
    if ($password -notmatch '[0-9]') {
        Write-Host "La contraseña debe contener al menos un número" -ForegroundColor Red
        return $false
    }
    
    # Validar caracteres especiales
    if ($password -match '[^a-zA-Z0-9@\-\.,_]') {
        Write-Host "La contraseña solo puede contener letras, números y @-.,_" -ForegroundColor Red
        return $false
    }
    
    # Validar caracteres repetidos
    $chars = $password.ToCharArray()
    $charCount = @{}
    foreach ($char in $chars) {
        if (-not $charCount.ContainsKey($char)) {
            $charCount[$char] = 1
        } else {
            $charCount[$char]++
            if ($charCount[$char] -gt 3) {
                Write-Host "No se puede repetir el mismo carácter más de 3 veces" -ForegroundColor Red
                return $false
            }
        }
    }
    
    return $true
}

function Add-FTPUser {
    try {
        do {
            $username = Read-Host "Ingrese nombre de usuario"
        } while (-not (Test-Username $username))
        
        do {
            $plainPassword = Read-Host "Ingrese contraseña"
        } while (-not (Test-Password $plainPassword))
        
        $password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
        
        $group = Read-Host "Seleccione grupo ($GROUP1/$GROUP2)"
        
        if ($group -notin @($GROUP1, $GROUP2)) {
            Write-Host "Grupo inválido" -ForegroundColor Red
            return
        }
        
        # Crear usuario
        $userParams = @{
            Name = $username
            Password = $password
            PasswordNeverExpires = $true
            UserMayNotChangePassword = $true
            Description = "Usuario FTP"
            ErrorAction = "Stop"
        }
        New-LocalUser @userParams
        
        #Asignar usuario a grupo
        Add-LocalGroupMember -Group $group -Member $username
        
        # Crear carpeta personal
        $personalDir = "$FTP_ROOT\$username"
        New-Item -ItemType Directory -Path $personalDir -Force
        
        # Configurar permisos
        $acl = New-Object System.Security.AccessControl.DirectorySecurity
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($username, "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule)
        Set-Acl $personalDir $acl
        
        # Crear enlaces simbólicos
        New-Item -ItemType SymbolicLink -Path "$personalDir\$group" -Target "$FTP_ROOT\$group" -Force
        New-Item -ItemType SymbolicLink -Path "$personalDir\Compartida" -Target "$FTP_ROOT\Compartida" -Force
        
        Write-Host "Usuario creado exitosamente" -ForegroundColor Green
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
    pause
}

function Show-FTPUsers {
    Write-Host "`nUsuarios FTP existentes:" -ForegroundColor Cyan
    Get-LocalUser | Where-Object {$_.Description -eq "Usuario FTP"} | 
    Format-Table Name, Enabled
    pause
}

# Bucle principal
do {
    $mainChoice = Show-MainMenu
    switch ($mainChoice) {
        "1" { Initialize-FTPServer }
        "2" { 
            do {
                $userChoice = Show-UserMenu
                switch ($userChoice) {
                    "1" { Add-FTPUser }
                    "2" { Show-FTPUsers }
                    "3" { break }
                    default { 
                        Write-Host "Opción inválida" -ForegroundColor Red
                        pause
                    }
                }
            } while ($userChoice -ne "3")
        }
        "3" { return }
        default {
            Write-Host "Opción inválida" -ForegroundColor Red
            pause
        }
    }
} while ($true)
