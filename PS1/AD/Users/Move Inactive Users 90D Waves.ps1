$Arxiu = Get-Content "C:\Users\enric.ferrer\Desktop\2.txt" -ErrorAction SilentlyContinue
$logFile = "C:\Users\enric.ferrer\Desktop\2.csv"

foreach ($user in $arxiu){
    Try{
        $Object = get-aduser $user -Properties *
        Set-ADUser $Object -Enabled $false
        Set-ADUser $Object -Replace @{adminDescription=$Object.DistinguishedName -replace "CN=$($object.name),",""}
        Move-ADObject $Object -TargetPath "OU=-011 USERS OUT COMPANY,DC=cosentinogroup,DC=net"
        Add-Content $logFile "Execucció OK: $User"
    } Catch {
        Add-Content $logFile "ERROR: $User"
    }
}