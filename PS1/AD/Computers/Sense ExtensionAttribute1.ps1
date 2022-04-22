Add-Content -path "C:\Users\enric.ferrer\Desktop\export.csv" -value ("Equipo" + ";" + "DistinguishedName" + ";" + "Enabled")
$Busca = Get-ADComputer -filter * -Properties * | Where-Object { ($_.DistinguishedName -notlike "*OU=-101 COMPUTERS DISABLED*") -AND ($_.DistinguishedName -notlike "*OU=Domain Controllers*") -AND ($_.DistinguishedName -notlike "*OU=Servers*") -AND ($_.DistinguishedName -notlike "*OU=Terminales Fabrica*")}
foreach ($Equip in $busca){
    If (!$equip.extensionattribute1){
        Add-Content -path "C:\Users\enric.ferrer\Desktop\export.csv" -value ($Equip.Name + ";" + $equip.DistinguishedName + ";" + $Equip.Enabled)
    }
}
        
    

