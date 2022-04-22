Add-Content -Path "c:\users\enric.ferrer\desktop\Export_Distribution_Lists_OU.csv" -Value ("User" + ";" + "Distribution List")
$groups = Get-ADGroup -Filter '*' -SearchBase 'OU=-004 DISTRIBUTION LISTS,DC=cosentinogroup,DC=net'
foreach ($grup in $groups){
    $users = Get-ADGroupMember $grup
    foreach ($user in $users){
        #Write-Host $user.SamAccountName ";" $grup.Name
        Add-Content -Path c:\users\enric.ferrer\desktop\Export_Distribution_Lists_OU.csv -Value ($user.SamAccountName + ";" + $grup.Name)
    }
}