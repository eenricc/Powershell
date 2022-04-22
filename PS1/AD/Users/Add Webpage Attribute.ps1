$ArxiuCSV = "C:\Users\enric.ferrer\Desktop\externos.csv" #DESAR EN UTF-8
$Users = Import-Csv -Delimiter ";" -Path "$ArxiuCSV"

foreach ($User in $Users) { 
    $Cerca = $User.name
    Try { $UsuariAD = Get-ADUser -Filter {EmailAddress -eq $cerca}  
    Set-ADUser $UsuariAD -HomePage "EXTERNO"
    Write-host "Usuario OK: " + $User.name
    } Catch { 
    Write-Host "Error en usuario:" + $User.name
    }

    
    
}