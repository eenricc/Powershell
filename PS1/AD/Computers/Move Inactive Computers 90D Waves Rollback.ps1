$Arxiu = Get-Content "C:\Users\enric.ferrer\Desktop\1.txt" -ErrorAction SilentlyContinue
$logFile = "C:\Users\enric.ferrer\Desktop\1.csv"

foreach ($computer in $arxiu){
    Try{
        $Object = Get-ADComputer $computer -Properties * 
        Set-ADComputer $Object -Enabled $true
        Move-ADObject $Object -TargetPath $object.adminDescription
        Add-Content $logFile "Execucció OK: $Computer"
    } Catch {
        Add-Content $logFile "ERROR: $computer"
    }
    
}