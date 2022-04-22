#SCRIPT COMPUTERS OU INCORRECTA
$cerca = Get-ADComputer -filter * -Properties * | Where-Object { ($_.DistinguishedName -notlike "*OU=Workstations*") -AND ($_.DistinguishedName -notlike "*OU=Servers*") -AND ($_.DistinguishedName -notlike "*OU=Apple MAC*") -AND ($_.DistinguishedName -notlike "*OU=Terminales Fabrica*") -AND ($_.DistinguishedName -notlike "*OU=Domain Controllers*") -AND ($_.DistinguishedName -notlike "*OU=-101 COMPUTERS DISABLED*")} | Select-Object Name, Enabled, LastLogonDate, DistinguishedName, operatingSystem 
Add-Content -Path "C:\ts_data\MWS\Reports\Export_OU_Incorrecta.csv" -Value ("Name" + ";" + "Enabled" + ";" + "LastLogonDate" + ";" + "DistinguishedName" + ";" + "OperatingSystem")
Foreach ($resultat in $cerca){
    Add-Content -Path "C:\ts_data\MWS\Reports\Export_OU_Incorrecta.csv" -Value ($resultat.Name + ";" + $resultat.Enabled + ";" + $resultat.LastLogonDate + ";" + $resultat.DistinguishedName + ";" + $resultat.operatingSystem)
}