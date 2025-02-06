#scripts 

#try/catch

try
{
    write-output "todo bien"
}
catch
{
    write-output "Algo lanzo una excepcion"
    write-output $_
}

try
{
    start-something -ErrorAction Stop
}
catch
{
    write-output "Algo genero una excepcion o uso Write-Error"
    write-output $_
}

#try/finally

$comando - [system.data.sqlclient.sqlcommand]:: new(querystring, connection)
try
{
    $comando.connection.open()
    $comando.ExecuteNonQuery
}
finally
{
    write-Error "Ha habido un problema con la ejecucion de la query, Cerrando la conexion"
    $comando.connection.close()
}

#Variable Automática $PSItem
 $PSItem.ToString() 

 $PSItem.InvocationInfo 

 $PSItem.ScriptStackTrace

 $PSItem.Exception

    $PSItem.Exception.Message 

    $PSItem.Exception.InnerException

    $PSItem.Exception.StackTrace

try
{
    start-something -path $path -ErrorAction Stop 
}
catch [System.IO.DirectoryNotFoundException],[System.IO.FileNotFoundException]
{
    write-output "El directorio o fichero no ha sido encontrado: [$path]"
}
catch [System.IO.IOException]
{
    write-output "Error de IO con el archivo: [$path]"
}

#otras formas de lanzar excepciones
throw "No se puede encontrar la ruta: [$path]"

throw [System.IO.FileNotFoundException] "No se puede encontrar la ruta: [$path]"

throw [System.IO.FileNotFoundException]::new()

throw [System.IO.FileNotFoundException]::new("No se puede encontrar la ruta: [$path]")

throw (New-Object -TypeName System.IO.FileNotFoundException)

throw (New-Object -TypeName System.IO.FileNotFoundException -Argumentlist "No se puede encontrar la ruta: [$path]")

#trap

trap 
{
    Write-Output $PSItem.ToString()
}
throw [System.Exception]::new('primero')
throw [System.Exception]::new('segundo')
throw [System.Exception]::new('tercero')

#Ejemplo practico de Script

#Función para realizar un backup del registro del sistema 
function Backup-Registry 
{
    Param(
        [Parameter (Mandatory = $true)] 
        [string] $rutaBackup
    )

    # Crear la ruta de destino del backup si no existe
    if (!(Test-Path -Path $rutaBackup)) {
        New-Item -ItemType Directory -Path $rutaBackup | Out-Null
    }

    # Generar un nombre único para el archivo de backup
    $nombreArchivo = "Backup-Registry_" + (Get-Date -Format "yyyy- MM-dd_HH-mm-ss") + ".reg"
    $rutaArchivo Join-Path Path $rutaBackup -ChildPath 
    $nombreArchivo

    # Realizar el backup del registro del sistema y guardarlo en el archivo de destino
    try 
    {
        Write-Host "Realizando backup del registro del sistema en $rutaArchivo..."

        reg export HKLM $rutaArchivo

        Write-Host "El backup del registro del sistema se ha realizado con éxito."
    }

    catch 
    {
        Write-Host "Se ha producido un error al realizar el backup del registro del sistema: $_"
    }

}

#escribir en el archivo de log

    $logDirectory = "$env:APPDATA\RegistryBackup"
    $LogFile = Join-path $logDirectory "backup-registry_log.txt"
    $LogEntry = "$(Get-Date) - $env:USERNAME - Backup -$backupPath"

    if(!(Test-Path $logDirectory))
    {
        New-Item -ItemType Directory -Path $logDirectory | Out-Null
    }
    Add-Content -Path $logFile -Value $LogEntry

#Comprobar que solo existan 10 Backups

    $backupCount = 10
    $backups = Get-ChildItem $backupDirectory -Filter *.reg | Sort-Object LasWriteTime -Descending
        if ($backups.count -gt $backupCount)
        {
            $backupsToDelete = $backups[$backupCount..($backups.Count - 1)]

            $backupsToDelete | Remove-Item -Force
        }

#Crear una carpeta con el modulo
$env:PSModulePath 

#Crear un .psd1

@{
    ModuleVersion ="1.0.0"
    PowerShellVersion = "5.1"
    RootModule = "Backup-Registry.ps1"
    Description = "Modulo para realizar backups del registro del sistema de Windows"
    Author = "Alice"
    FunctionsToExport = @("Backup-Registry")
}

#importar el modulo
    Import-Module BackupRegistry

#Comprobar que el modulo funciona
    BackupRegistry -rutaBackup 'D:\tmp\Backups\registro\'

#automatizacion del backup
    Register-ScheduledTask 

    
