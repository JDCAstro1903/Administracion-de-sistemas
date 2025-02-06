#funciones

Function [<ambito> :] <Nombre de funcion> (<argumento>)
{
    param (<Lista de parametros>)
    #Bloque de instrucciones
}

Get-Verb

Function Get-Fecha
{
    Get-date
}

 Get-ChildItem -Path Function:\*-*

 Get-ChildItem -Path Function:\NombreFunc | Remove-Item

 Function Get-resta
 {
    param([int]$num1, [int]$num2)
    $resta=$num1-$num2
    Write-host "la resta de los parametros es $resta"
 }

 Get-resta 10 5 


#convertir funcion PS a funcion avanzada

function Get-resta
{
    [CmdletBinding()]
    param([int]$num1, [int]$num2)
    $resta=$num1-$num2
    Write-host "la resta de los parametros es $resta"
}

#explorar con profundidad los parametros 
(Get-Command -name Get-resta).Parameters.Keys

#exponer informacion
function Get-resta
{
    [CmdletBinding()]
    param([int]$num1, [int]$num2)
    $resta=$num1-$num2
    Write-Verbose -Message "la operacion que va a realizar una resta de $num1 y $num2"
    Write-host "la resta de los parametros es $resta"
}