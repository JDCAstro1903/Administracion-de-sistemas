Get-Service -Name "LSM" | Get-Member 

Get-Service -Name "LSM" | Get-Member  -Member Property


Get-Item .\test.txt | Get-Member -MemberType Method

Get-Item .\test.txt | Select-Object Name, Legth

Get-Service | Select-Object -Last 5
Get-Service | Select-Object -First 5

#where object
Get-Service | Where-Object {$_.Status -eq "Running"}

#metodos
(Get-Item .\test.txt).IsReadOnly
(Get-Item .\test.txt).IsReadOnly = 1


Get-ChildrenItem.*txt

(Get-Item .\test.txt).CopyTo("D:\Desktop\Prueba.txt")

(Get-Item .\test.txt).Delete()
Get-ChildrenItem.*txt

$MiObjeto = New-Object PSObject

$MiObjeto | Add-Member -MemberType NoteProperty -Name Nombre -Value "Miguel"
$MiObjeto | Add-Member -MemberType NoteProperty -Name Edad -Value 23
$MiObjeto | Add-Member -MemberType ScriptMethod -Name Saludar -Value {Write-host "Hola mundo"}

#pipeline
Get-Process -Name Acrobat | Stop-Process

Get-Help -full Get-Process
Get-Help -full Stop-Process

Get-Help -full Get-ChildrenItem
Get-Help -full Get-Clipboard



