cat .\condicionales.ps1
$condicion = $true
if ($condicion)
{
    write-output "La condicion era verdadera"
}
else
{
    write-output "la condicion era falsa"
}

.\condicionales.ps1


cat .\condicionales2.ps1

$numero = 2
if ($numero -ge 3)
{
    write-output "el numero [$numero] es mayor o igual que 3"
}
elseif ($numero lt 2)
{
    write-output "el numero [$numero] es menor que 2"
}
else
{
    write-output "El numero [$numero] es igual a 2"
}

.\condicionales2.ps1



