$PaginaInici = 001104
$PaginaFinal = 295465
$Pagina = 1

While ($PaginaInici -le $PaginaFinal) {
    Invoke-WebRequest -Uri "http://inmanga.com/Page/GetPageImage/?identification=$PaginaInici" -OutFile "C:\Enric\$pagina.jpg"
    $PaginaInici = $PaginaInici + 1
    $Pagina = $Pagina + 1
}

