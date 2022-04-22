$date = (Get-Date).AddYears(-1)

#VALIDAR DINS OU CONCRETA
$info = Get-ADComputer -Filter {LastLogonTimestamp -gt $date} -Properties * | Where-Object {($_.DistinguishedName -like "*OU=-101 COMPUTERS DISABLED*")} |Select-Object Name, Enabled, LastLogonDate, DistinguishedName,OperatingSystem | Export-Csv -Path "C:\ts_data\Scripts AD\comp_validate.csv" -Delimiter ";" -Encoding UTF8

#VALIDAR FORA DE OUS CONCRETEDS
$info = Get-ADComputer -Filter {LastLogonTimestamp -gt $date} -Properties * | Where-Object { ($_.DistinguishedName -notlike "*OU=Workstations*") -AND ($_.DistinguishedName -notlike "*OU=Servers*") -AND ($_.DistinguishedName -notlike "*OU=Apple MAC*") -AND ($_.DistinguishedName -notlike "*OU=Terminales Fabrica*") -AND ($_.DistinguishedName -notlike "*OU=Domain Controllers*")}  | Select-Object LastLogonDate, Name, Enabled, OperatingSystem, DistinguishedName | Export-Csv -Path "C:\ts_data\Scripts AD\Comp_Validate_NO_OUS.csv" -Delimiter ";" -Encoding UTF8
