#administracions de usuarios y grupos

get-localUser #da informacion detallada sobre los usuarios localUser

Get-LocalUser -name Miguel | Select-Object * # filtra por nombre

Get-LocalUser -SID S-1-5-21-619924196-4045554399-1956444298-500 | Select-Object * # filtra por SID


Get-LocalGroup #obtiene informacion de los grupos locales

Get-LocalGroup -name Administradores | Select-Object * #filtra por nombre


New-LocalUser -name "usuario1" -Description "usuario de prueba" -noPassword
#Crea un usuario sin contraseña

New-LocalUser -name "usuario2" -Description "usuario de prueba 2" -Password (ConvertTo-securestring -asPlaintext "12345" -force)
#usuario con contraseña

#eliminar usuario

Get-LocalUser -Name "usuario1"
Remove-LocalUser -Name "usuario1"


#crear un grupo local

New-LocalGroup -name "grupo1" -Description "grupo de prueba"

#agregar miembro

Add-LocalGroupMember -Group grupo1 -member Usuario2 -Verbose

#obtener miembros del grupo
Get-LocalGroupMember grupo 1

#quitar miembros
Remove-LocalGroupMember -group grupo1 -member usuario1

#Eliminar un grupo
Remove-LocalGroup -name "grupo1"

