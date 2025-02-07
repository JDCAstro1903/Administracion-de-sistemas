#Administracion con PowerShell

#Administracion de servicios

Get-Service #Obtener los servicios

 -Name          #indica el nombre del servicio
 -DisplayName   #busca por palabras clave

 Get-Service | Where-Object {$_.Status -eq "Running"} #se filtra por su propiedad de status


#Filtrar servicios que se inicien de manera automatica
Get-Service | Where-Object {$_.StartType -eq "Automatic"} | Select-Object Name, StartType   

DependentServices #Obtiene servicios que dependan del servicio que se indique 

RequiredServices  #Obtiene servicios de los que depende el servicio indicado

#detener servcios
Stop-Service
    -Name       #Nombre del servicio
    -PassThru   #para devolver un objeto que represente al servicio
    -Confirm    #Confirmacion
#Ejemplo
Stop-Service -Name Spooler -Confirm -PassThru

#iniciar servicios
Start-Service

#pausar servicios
Suspend-Service

#No todos los servicios se pueden suspender
CanPauseAndContinue 

#Ejemplos
Get-Service | Where-Object CanPauseAndContinue -eq true

#Si no se puede suspender marcara error

#Restart-Service|Reinicia un servicio

Restart-Service -Name WSearch -Confirm -PassThru #Ejemplo

#Set-Service | Cambia la configuracion de un servicio
Set-Service -Name dcsvc -DisplayName "Servicio de virtualizacion de credenciales de seguridad distribuido"

#StartupType | cambia el tipo de inicio de un servicio en concreto
Set-Service -Name BITS StartupType Automatic -Confirm -PassThru | Select-Object Name, StartType

#Description | cambia la descripcion de un servicio
Set-Service -name BITS -Description "Transfiere archivos en segundo plano mediante el uso de ancho de banda de red inactivo"

#si no tienen descripcion se ejecuta el siguiente comando
Get-CimInstance Win32_Service -filter 'Name = BITS' | Format-List Name, Description

#Iniciar | parar | suspender un servicio
Set-Service -Name Spooler -Status Running | Paused | Stopped -Confirm -PassThru






