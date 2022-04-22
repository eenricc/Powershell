Import-Module ActiveDirectory

#CSV HA DE TENIR COLUMNES: SamAccountName
$FileCSV = "C:\Users\41000790r\Desktop\Add_Users_to_Group.csv"
$GroupName = "Test_Group"

$TotalOK = 0
$TotalKO = 0
$Problema = "No"

$ImportCSV = Import-Csv $FileCSV 

ForEach ($Usuaris in $ImportCSV){
    $User = $Usuaris.SamAccountName
    $UsuariAD = Get-ADUser -Filter {SamAccountName -eq $User}
    If ($UsuariAD -ne $null){
        Try {Add-ADGroupMember -Identity $GroupName -Members $UsuariAD} catch {$Problema = "Si"}
        If ($Problema -eq "No"){
            Write-host "Usuari existeix OK:" $UsuariAD.SamAccountName -ForegroundColor Green
            $TotalOK = $TotalOK + 1
        } else {
            Write-host "Error al afegir a grup:" $User -ForegroundColor Red
            $TotalKO = $TotalKO + 1
        }
    } else {
        Write-host "Usuari NO existeix:" $User -ForegroundColor Red
        $TotalKO = $TotalKO + 1
    }
}

Write-host "------------------------------" -ForegroundColor Yellow
Write-host "Total OK:" $TotalOK -ForegroundColor Yellow
Write-host "Total KO:" $TotalKO -ForegroundColor Yellow
