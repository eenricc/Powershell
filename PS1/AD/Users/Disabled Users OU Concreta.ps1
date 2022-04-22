#REPORT DISABLED USERS OU CONCRETA
$data = Get-date -Format ddMMyy
$path = "C:\ts_data\mws\DisabledUsers\Disabled_Users_$data.csv"
Add-Content -Path $path -Value ("UID" + ";" + "OU" + ";" + "Description")

$users = Get-ADUser -Filter {Enabled -eq $false} -SearchBase "OU=-001 COSENTINO USERS,DC=cosentinogroup,DC=net" -properties * 
foreach ($user in $users){
    Add-Content -Path $path -Value ($user.samAccountName + ";" + $user.CanonicalName + ";" + $user.description)  
}