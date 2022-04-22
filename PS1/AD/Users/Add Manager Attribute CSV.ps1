$ArxiuCSV = "C:\Users\enric.ferrer\Desktop\libro1.csv" #DESAR EN UTF-8
$Users = Import-Csv -Delimiter ";" -Path "$ArxiuCSV"

foreach ($User in $Users) { 
    $UsuariAD = Get-ADUser $user.SamAccountName
    Set-ADUser $UsuariAD -manager $user.Manager
    
    
}