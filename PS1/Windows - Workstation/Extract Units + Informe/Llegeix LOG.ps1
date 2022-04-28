#Carpeta de red donde se encuentran los archivos extraidos de los PCs
#$path = "\\10.10.10.29\Publica\ts_data"
$path = "c:\temp"
$carpeta = Get-ChildItem $path
#Ruta on desarem el CSV
$rutadesti = "c:\temp\1.csv"


#Afegim contingut al arxiu que generarem (maquina local)
Add-Content "EQUIPO `t USUARIO `t DOMINIO `t UNIDAD `t RUTA" -path $rutadesti

Foreach ($arxiu in $carpeta){
    $contingut = Get-Content -path "$path\$arxiu" 
    Add-Content $contingut -path $rutadesti
    Add-Content "" -path $rutadesti
}


