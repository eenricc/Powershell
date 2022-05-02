##*=============================================================================================================================================
##* SCRIPT: Mou clean roms del Romset FB Alpha v0.2.97.42
##*=============================================================================================================================================

##*=============================================================================================================================================
##* INFORMACIÓ
##*=============================================================================================================================================
	
##* - $file_list = Indicar ruta de l'arxiu fba_noclones.txt. Aquest conté el nom de roms de FBA sense clons i sense 4player.	
##*	- $search_folder = Carpeta on estan els arxius indicats a la llista anterior.
##*	- $destination_folder = Carpeta on es mouran els arxius de FBA localitzats.
##*	- $Logfile = Ruta on desarem el log. Aquest mostrarà unicament els errors de copia.

##*=============================================================================================================================================
##* VARIABLES
##*=============================================================================================================================================

$file_list = Get-Content "D:\02 - ROMS\FB Alpha v0.2.97.42\fba_noclones_noNeoGeo.txt"
$search_folder = "D:\02 - ROMS\FB Alpha v0.2.97.42\roms"
$destination_folder = "D:\02 - ROMS\FB Alpha v0.2.97.42\FBA v0.2.97.42"
$Logfile = "D:\02 - ROMS\FB Alpha v0.2.97.42\error.log"

##*=============================================================================================================================================
##* FUNCIONS
##*=============================================================================================================================================

function writeLog ($inicial, $desti){
    Add-content $Logfile -value "-------------------------
    Status: FAILED
    Arxiu a moure: $inicial
    Carpeta destí: $desti"
}

##*=============================================================================================================================================
##* MAIN
##*=============================================================================================================================================

foreach ($file in $file_list) {
    $file_to_move = Get-ChildItem -Path $search_folder -Filter $file -Recurse -ErrorAction SilentlyContinue -Force | % { $_.FullName}
    if ($file_to_move) {
        Move-Item $file_to_move $destination_folder
    } else {
        writeLog "$file" "$destination_folder"
    }
}