Clear-Content -path 1.csv
Out-File -FilePath 1.csv -InputObject ("ESTAT" + "," + "DATA_EXPIRACIO" + "," + "USUARI")
$Users = Get-ADUser -filter * -SearchBase "OU=T-System,OU=EXTERNAL,OU=07 EXTERNAL USERS,OU=-001 COSENTINO USERS,DC=cosentinogroup,DC=net" -Properties accountExpires

foreach ($persona in $users){
    $lngValue = $persona.accountExpires
    If (($lngValue -eq 0) -or ($lngValue -gt [DateTime]::MaxValue.Ticks)){
        Write-Host "NO EXPIRA: " $persona.name -ForegroundColor green
        Out-File -FilePath 1.csv -InputObject ("ACTIU" + "," + "NO EXPIRA" + "," + $persona.name)  -append
    }Else{
        $Date = [DateTime]$lngValue
        $AcctExpires = $Date.AddYears(1600).ToLocalTime()     
        $dataexpiracio = ($AcctExpires).ToString("yyyy-MM-dd")

        $today = Get-Date -format yyyy-MM-dd
        $onemonth = (Get-Date).AddDays(30).ToString("yyyy-MM-dd")

        if($onemonth -le $dataexpiracio){
            Write-Host "EXPIRA EL: " $AcctExpires "| USUARI: " $persona.name -ForegroundColor green
            Out-File -FilePath 1.csv -InputObject ("ACTIU" + "," + "$AcctExpires" + "," + $persona.name)  -append
        }else{
            if ($today -le $dataexpiracio){
                Write-Host "EXPIRA EN BREU: " $AcctExpires "| USUARI: " $persona.name -ForegroundColor yellow
                Out-File -FilePath 1.csv -InputObject ("ACTIU" + "," + "$AcctExpires" + "," + $persona.name)  -append
                
            }else{
               Write-Host "EXPIRAT DES DE: " $AcctExpires "| USUARI: " $persona.name  -ForegroundColor red
               Out-File -FilePath 1.csv -InputObject ("EXPIRAT" + "," + "$AcctExpires" + "," + $persona.name)  -append
            }
        }
        
    }

}


