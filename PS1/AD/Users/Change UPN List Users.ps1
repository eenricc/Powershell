$Dades = Import-Csv "c:\users\enric.ferrer\desktop\Libro1.csv" -Delimiter ";"
$Distinguished = ",OU=Fabrica,OU=GENERIC,OU=-020 OTHER USERS,DC=cosentinogroup,DC=net"
$logFile = "C:\Users\enric.ferrer\Desktop\CanviNomFabrica.csv"

foreach ($usuari in $dades){
    $Antic = $usuari.antic
    $Nou = $usuari.nou
    Try {
    Get-ADUser $Antic -properties *
    Set-ADUser $antic -UserPrincipalName "$nou@cosentino.com" -SamAccountName $nou -DisplayName "$nou Fabrica" -GivenName $nou -Replace @{adminDescription=$Antic}
    Rename-ADObject -Identity "CN=$Antic Fabrica$Distinguished" -NewName "$Nou Fabrica"
    Add-Content $logFile "OK: $Antic --> $Nou"
    } catch {
    Add-Content $logFile "KO: $Antic"
    }

}
