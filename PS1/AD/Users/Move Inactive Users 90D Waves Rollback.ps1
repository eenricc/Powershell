$Arxiu = Get-Content "C:\Users\enric.ferrer\Desktop\2.txt" -ErrorAction SilentlyContinue
$logFile = "C:\Users\enric.ferrer\Desktop\2.csv"

foreach ($user in $arxiu){
    Try{
        $Object = get-aduser $user -Properties *
        Set-ADUser $Object -Enabled $true
        Move-ADObject $Object -TargetPath $object.adminDescription
        Add-Content $logFile "Execucció OK: $User"
    } Catch {
        Add-Content $logFile "ERROR: $User"
    }
}