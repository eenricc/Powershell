$ArxiuCSV = "C:\Users\enric.ferrer\Desktop\logon_script.txt"
$Users = Get-Content $ArxiuCSV

foreach ($User in $Users) { 
    Try { $UsuariAD = Get-ADUser $User
    Set-ADUser $UsuariAD -ScriptPath INVLOG-ES.BAT
    Write-host "Usuario OK: " $User
    } Catch { 
    Write-Host "Error en usuario:" $User
    }

    
    
}