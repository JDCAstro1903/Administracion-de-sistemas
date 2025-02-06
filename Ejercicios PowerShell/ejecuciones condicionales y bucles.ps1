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

<condicion> ? <if-true> : <if-false>

switch (<test-expression>) {
    <result1-to-be-matched> { <action> }
    <result2-to-be-matched> { <action> }
}

if (<result1-to-be-matched> -eq (<test-expression>)) { <action> }
if (<result2-to-be-matched> -eq (<test-expression>)) { <action> }

switch [-regex | -wildcard | -exact] [-casesensitive] [(<test-expression>) | -file filename]
{
    result1-to-be-matched { <action> }
    <result2-to-be-matched> { <action> }
    "string" | number | variable | { <value-scriptblock> } { <action> }
    ...
    default { <action> } # Opcional
}

switch (3)
{
    1 { "[ $_ ] es uno." }
    2 { "[ $_ ] es dos." }
    3 { "[ $_ ] es tres." }
    4 { "[ $_ ] es cuatro." }
    3 { "[ $_ ] tres de nuevo." }
}

switch (1, 5)
{
    1 {"[$_] es uno."}
    2 {"[$_] es dos."}
    3 {"[$_] es tres."}
    4 {"[$_] es cuatro."}
    5 {"[$_] es cinco."}
}

switch ("seis")  
{  
    1 {"[$_] es uno." ; Break}  
    2 {"[$_] es dos."; Break}  
    3 {"[$_] es tres."; Break}  
    4 {"[$_] es cuatro."; Break}  
    5 {"[$_] es cinco."; Break}  
    "se*" {"[$_] coincide con se*."}  
    Default {  
        "No hay coincidencias con [_$]"  
    }  
}  


$email = 'antonio.yanez@udc.es'
$email2 = 'antonio.yanez@usc.gal'
$url = 'https://www.dc.fi.udc.es/~afyanez/Docencia/2023'

switch -Regex ($url, $email, $email2)
{
    '^\w+[-.\w]*@(udc|usc|edu)\.(es|gal)$' { "[$_] es una direccion de correo electronico academica" }
    '^ftp://.*$' { "[$_] es una direccion ftp" }
    '^(http[s]?)://.*$' { "[$_] es una direccion web, que utiliza [$(matches[1])]" }
}

