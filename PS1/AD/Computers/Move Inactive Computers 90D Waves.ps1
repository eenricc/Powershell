$Arxiu = Get-Content "C:\Users\enric.ferrer\Desktop\1.txt" -ErrorAction SilentlyContinue
$logFile = "C:\Users\enric.ferrer\Desktop\1.csv"


foreach ($computer in $arxiu){
    Try{
        $Object = Get-ADComputer $computer -Properties * 
        Set-ADComputer $Object -Enabled $false
        Set-ADComputer $Object -Replace @{adminDescription=$Object.DistinguishedName -replace "CN=$($object.name),",""}
        Move-ADObject $Object -TargetPath "OU=-101 COMPUTERS DISABLED,DC=cosentinogroup,DC=net"
        Add-Content $logFile "Execucció OK: $Computer"
    } Catch {
        Add-Content $logFile "ERROR: $computer"
    }
    
}