$equips = (Get-ADComputer -Filter * -SearchBase "OU=HQ_Spain,OU=Europe,OU=Workstations,DC=cosentinogroup,DC=net" | Get-Random -Count 100).name
$comptador = 0


Foreach ($name in $equips){
    if (Test-Connection -ComputerName $name -Count 1 -ErrorAction SilentlyContinue){
        If ($comptador -lt 2){
            Write-Host "$name" -ForegroundColor Green
            $comptador++
        }Else{
            break
        }       
    }
}
