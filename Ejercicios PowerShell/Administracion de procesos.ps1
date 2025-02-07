Get-Process #Informacion sobre los procesos en ejecucion

#Filtros para busqueda 
    -Name 
    -Id

#Parametros 
    -FileVersionInfo #muestra informacion de version

    -IncludeUserName #Muestra al propietario de proceso

    -Module          #Muestra los modulos cargados por el proceso

#Stop-Process
Stop-Process -Name Acrobat -Confirm -PassThru   #Detiene un proceso por nombre

Stop-Process -Id 10940 -Confirm -PassThru   #Detiene un proceso por Id

Get-Process -Name Acrobat  | Stop-Process -Confirm -PassThru

#Start-Process
    -FilePath #Ruta del archivo
    -PassThru #devuelve un objeto que representa el proceso

    #Ejemplo
    Start-Process -FilePath "C:\Windows\System32\Notepad.exe" -PassThru

    -ArgumentList       #Especifica los argumentos que van a pasar al proceso
    -WorkingDirectory   #Especifica el directorio del proceso que se esta iniciando 

    #Ejemplo
    Start-Process -FilePath "Cmd.exe" -ArgumentList"/c mkdir NuevaCarpeta" WorkingDirectory "C:\Documents\FIC\A50" -PassThru

    -WindowStyle        #Especifica el estilo de ventana que se esta iniciando 
        -Normal
        -Maximized
        -Minimized
        -Hidden
    #Ejemplo
    Start-Process -FilePath "notepad.exe" -WindowStyle "Maximized" -PassThru

    -Verb               #Especifica la accion que se llevara a cabo
        -open
        -print
        -edit
        -copy
        -paste
    #ejemplo
    Start-Process -FilePath "C:\Windows\System32\Notepad.exe" -verb Print-PassThru

#Wait-Process
    #Espera a que un proceso en ejecucion se detenga 
    -Name
    -Id
##96








