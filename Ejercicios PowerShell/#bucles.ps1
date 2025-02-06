#bucles 

for (<Init>; <condition>; <repeat>){
    <statement list>
}

for (($i = 0), ($j = 0); $i -lt 5; $i++)
{
    "$i:$i"
    "$j:$j"
}


foreach ($<item> in $<collection>) {<statement list>}

MoveNext 

$foreach. MoveNext

reset

current

$ssoo = "freebsd", "openbsd", "solaris", "fedora", "ubuntu", "netbsd"
foreach ($so in $ssoo) {
    Write-Host $so
}

foreach ($archivo in Get-ChildItem) {
    if ($archivo.length -ge 10KB) {
        Write-Host "$archivo -> [$($archivo.length)]"
    }
}


while (<condition>) {<statement list>}

$num = 0

while ($num -ne 3)
{
    $num++
    Write-host $num
}

$num = 0

while ($num -ne 5)
{
    if ($num -eq 1) { $num = $num + 3 ; continue}
    $num++
    Write-host $num
}


do {<statement list>} until (<condition>)

do {<statement list>} while (<condition>)

$valor = 5
$multiplicacion = 1

do
{
    $multiplicacion = $multiplicacion * $valor

    $valor--
}

while ($valor -gt 0)

Write-Host $multiplicacion


$valor = 5
$multiplicacion = 1

do
{
    $multiplicacion = $multiplicacion * $valor

    $valor--
}

until ($valor -gt 0)

Write-Host $multiplicacion