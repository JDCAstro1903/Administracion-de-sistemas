# Función para instalar Chocolatey si no está presente
function Install-Chocolatey {
    try {
        if (!(Test-Path "C:\ProgramData\chocolatey")) {
            Write-Host "Instalando Chocolatey..." -ForegroundColor Cyan
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            refreshenv
        }
    }
    catch {
        Write-Host "Error instalando Chocolatey: $_" -ForegroundColor Red
        exit
    }
}

# Función para verificar si un puerto está en uso
function Test-PortInUse {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateRange(1,65535)]
        [int]$Port
    )
    try {
        $tcpConnections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
        return $null -ne $tcpConnections
    }
    catch {
        Write-Host "Error verificando puerto: $_" -ForegroundColor Red
        return $true
    }
}

# Función para solicitar y validar un puerto
function Get-ValidPort {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    do {
        try {
            [int]$port = Read-Host $Message
            if ($port -lt 1 -or $port -gt 65535) {
                Write-Host "Puerto inválido. Use un número entre 1 y 65535" -ForegroundColor Red
                continue
            }
            if (Test-PortInUse -Port $port) {
                Write-Host "El puerto $port ya está en uso. Ingrese otro." -ForegroundColor Red
                continue
            }
            return $port
        }
        catch {
            Write-Host "Error: Ingrese un número válido" -ForegroundColor Red
        }
    } while ($true)
}

# Función para instalar y configurar IIS
function Install-IIS {
    param (
        [Parameter(Mandatory=$true)]
        [int]$Port
    )
    try {
        Write-Host "Instalando IIS..." -ForegroundColor Cyan
        Install-WindowsFeature -name Web-Server -IncludeManagementTools
        Write-Host "Configurando IIS en el puerto $Port..." -ForegroundColor Cyan
        Import-Module WebAdministration
        Set-ItemProperty "IIS:\Sites\Default Web Site" -Name bindings -Value @{protocol="http";bindingInformation="*:$Port :"}
        Restart-Service W3SVC
        Write-Host "IIS instalado y configurado correctamente" -ForegroundColor Green
    }
    catch {
        Write-Host "Error configurando IIS: $_" -ForegroundColor Red
    }
}

# Función para instalar y configurar el segundo servidor web
function Install-SecondWebServer {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("Apache", "Nginx", "Tomcat")]
        [string]$Server,
        
        [Parameter(Mandatory=$true)]
        [int]$Port
    )
    
    try {
        switch ($Server) {
            "Apache" {
                Write-Host "Instalando Apache..." -ForegroundColor Cyan
                choco install apache-httpd -y
                $configFile = "C:\tools\Apache24\conf\httpd.conf"
                if (Test-Path $configFile) {
                    (Get-Content $configFile).replace("Listen 80", "Listen $Port") | Set-Content $configFile
                    Start-Service Apache24
                }
            }
            "Nginx" {
                Write-Host "Instalando Nginx..." -ForegroundColor Cyan
                choco install nginx -y
                $configFile = "C:\nginx\conf\nginx.conf"
                if (Test-Path $configFile) {
                    (Get-Content $configFile).replace("listen 80;", "listen $Port;") | Set-Content $configFile
                    Start-Process -NoNewWindow -FilePath "C:\nginx\nginx.exe"
                }
            }
            "Tomcat" {
                Write-Host "Instalando Tomcat..." -ForegroundColor Cyan
                choco install tomcat -y
                $configFile = "C:\Program Files\Apache Software Foundation\Tomcat 9.0\conf\server.xml"
                if (Test-Path $configFile) {
                    (Get-Content $configFile).replace('<Connector port="8080"', "<Connector port=`"$Port`"") | Set-Content $configFile
                    Start-Service Tomcat9
                }
            }
        }
        Write-Host "$Server instalado y configurado correctamente en el puerto $Port" -ForegroundColor Green
    }
    catch {
        Write-Host "Error instalando $Server : $_" -ForegroundColor Red
    }
}

# Función principal
function Main {
    Clear-Host
    Write-Host "=== INSTALACIÓN DE SERVIDORES WEB ===" -ForegroundColor Cyan
    Write-Host "`nPuertos comúnmente ocupados:" -ForegroundColor Yellow
    Write-Host " - 80 (HTTP - IIS, Apache, Nginx)"
    Write-Host " - 443 (HTTPS - IIS, Apache, Nginx)"
    Write-Host " - 8080 (Tomcat, Proxy)"
    Write-Host " - 3306 (MySQL)"
    Write-Host " - 1433 (SQL Server)"
    Write-Host " - 22 (SSH)"
    
    Write-Host "`nPuertos recomendados:" -ForegroundColor Green
    Write-Host " - 8081, 8082, 8888, 9000, 9090, 9191`n"

    Install-Chocolatey

    $puertoIIS = Get-ValidPort "Ingrese el puerto para IIS"
    Install-IIS -Port $puertoIIS

    do {
        $servidorAdicional = Read-Host "`nSeleccione el segundo servidor web (Apache/Nginx/Tomcat)"
    } while ($servidorAdicional -notmatch '^(Apache|Nginx|Tomcat)$')

    $puertoOtro = Get-ValidPort "Ingrese el puerto para $servidorAdicional"
    Install-SecondWebServer -Server $servidorAdicional -Port $puertoOtro
}

# Ejecutar el script
Main
