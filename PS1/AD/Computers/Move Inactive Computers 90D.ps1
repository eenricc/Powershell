$arxiu = Get-Date -Format "dd-MM-yyyy"
$date = (Get-Date).AddDays(-90)
$info = Get-ADComputer -Filter {LastLogonTimestamp -lt $date} -Properties Name, CanonicalName, LastLogonTimestamp, LastLogonDate, enabled | Where-Object {($_.DistinguishedName -notlike "*OU=Domain Controllers*") -and ($_.DistinguishedName -notlike "*OU=-101 COMPUTERS DISABLED*") -and ($_.DistinguishedName -notlike "*OU=Servers*") -and ($_.DistinguishedName -notlike "*OU=Terminales Fabrica*") -and ($_.DistinguishedName -notlike "*OU=00 Azure*") -and ($_.DistinguishedName -notlike "*OU=Windows Virtual Desktop*")} | Export-Csv -Path C:\users\enric.ferrer\Desktop\$arxiu.csv -Delimiter ";" -Encoding UTF8


ForEach ($pc in $info) {
    $computer = Get-ADComputer $pc -Properties *
    Set-ADComputer $pc -Enabled $false
    Set-ADComputer $pc -Replace @{adminDescription=$computer.DistinguishedName -replace "CN=$($computer.Name),",""}
    Move-ADObject $User -TargetPath "OU=-101 COMPUTERS DISABLED,DC=cosentinogroup,DC=net"
    Write-Host "Execucció OK: $pc.name"
}

