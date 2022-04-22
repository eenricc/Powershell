$arxiu = Get-Date -Format "dd-MM-yyyy"
$date = (Get-Date).AddDays(-90)
$info = Get-ADUser -Filter {LastLogonTimestamp -lt $date} -Properties Name, CanonicalName, LastlogonTimestamp, LastLogonDate, Enabled | Where-Object {($_.DistinguishedName -notlike "*OU=-020 OTHER USERS*") -and ($_.DistinguishedName -notlike "*OU=-011 USERS OUT COMPANY*") -and ($_.DistinguishedName -notlike "*CN=Users*")} | Export-Csv -Path C:\users\enric.ferrer\Desktop\$arxiu.csv -Delimiter ";" -Encoding UTF8


ForEach ($Object in $info) {
    $User = get-aduser $Object -Properties *
    Set-ADUser $Object -Enabled $false
    Set-ADUser $Object -Replace @{adminDescription="$User.DistinguishedName" -replace "CN=$($User.Name),",""}
    Move-ADObject $User -TargetPath "OU=-011 USERS OUT COMPANY,DC=cosentinogroup,DC=net"
    Write-Host "Execucció OK: $Object.SamAccountName"
}



