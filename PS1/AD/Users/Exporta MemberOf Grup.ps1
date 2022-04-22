Add-Content -path "C:\Users\enric.ferrer\Desktop\WSUS_Grupos.csv" -value ("Equipo" + ";" + "Fase")
$Piloto = Get-ADGroupMember "Wsus Piloto" -Recursive 
$MediosF1 = Get-ADGroupMember "WSUS Equipos Medios F1" -Recursive 
$MediosF2 = Get-ADGroupMember "WSUS Equipos Medios F2" -Recursive 
$MediosF3 = Get-ADGroupMember "WSUS Equipos Medios F3" -Recursive 
$MediosF4 = Get-ADGroupMember "WSUS Equipos Medios F4" -Recursive 
$Criticos = Get-ADGroupMember "WSUS Fabrica Criticos" -Recursive 
$RolServer = Get-ADGroupMember "WSUS Workstations Rol Server" -Recursive 

Function agregaInfo($dades, $fase){
    ForEach ($equip in $dades){
        Add-Content -path "C:\Users\enric.ferrer\Desktop\WSUS_Grupos.csv" -value ($equip.Name + ";" + $fase)
    }
}

agregaInfo $Piloto "Fase Piloto"
agregaInfo $MediosF1 "Fase Equipos Medios F1"
agregaInfo $MediosF2 "Fase Equipos Medios F2"
agregaInfo $MediosF3 "Fase Equipos Medios F3"
agregaInfo $MediosF4 "Fase Equipos Medios F4"
agregaInfo $Criticos "Fase Equipos Criticos"
agregaInfo $RolServer "Fase Equipos con Rol Servidor"

