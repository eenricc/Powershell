# CSV HA DE TENIR COLUMNA: pc ; usuario
$Equipos = Import-Csv "C:\Users\enric.ferrer\Desktop\computer_name.csv" -Delimiter ";" #DESAR EN UTF8

Foreach ($Equipo in $Equipos){
    #Exportació del camp AdminDescription
    $Resultat = Get-ADComputer $equipo.PC -Properties "extensionattribute1"
    Add-Content -path "C:\Users\enric.ferrer\Desktop\export.csv" -value ($Equipo.PC + ";" + $equipo.Usuario + ";" + $Resultat.extensionattribute1)

    #Modificació del camp AdminDescription
    #Set-ADComputer $equipo.pc -replace @{extensionattribute1 = $equipo.usuario} 
}

