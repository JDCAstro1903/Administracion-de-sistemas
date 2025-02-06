#break 
$num = 10

for ($i = 2; $i -lt 10; $i++) {
    $num = $num + $i
    if ($i -eq 5) { Break }
}

Write-Host $num
Write-Host $i


$cadena = "Hola, buenas tardes"
$cadena2 = "Hola, buenas noches"

switch -Wildcard ($cadena, $cadena2) {
    "Hola, buenas*" { "[$_] coincide con [Hola, buenas*]" }
    "Hola, bue*"    { "[$_] coincide con [Hola, bue*]" }
    "Hola,*"        { "[$_] coincide con [Hola,*]"; Break }
    "Hola, buenas tardes" { "[$_] coincide con [Hola, buenas tardes]" }
}

#continue
$num = 10

for ($i = 2; $i -lt 10; $i++) {
    $num = $num + $i
    if ($i -eq 5) { continue }
}

Write-Host $num
Write-Host $i


$cadena = "Hola, buenas tardes"
$cadena2 = "Hola, buenas noches"

switch -Wildcard ($cadena, $cadena2) {
    "Hola, buenas*" { "[$_] coincide con [Hola, buenas*]" }
    "Hola, bue*"    { "[$_] coincide con [Hola, bue*]" }
    "Hola,*"        { "[$_] coincide con [Hola,*]"; continue }
    "Hola, buenas tardes" { "[$_] coincide con [Hola, buenas tardes]" }
}


