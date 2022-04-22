Add-Content -path "C:\Users\enric.ferrer\Desktop\domain_admins.csv" -value ("Name" + ";" + "DistinguishedName" + ";" + "SamAccountName")
$domainAdmins = Get-ADGroupMember "Domain Admins" -Recursive 
Foreach ($admin in $domainAdmins){
    Add-Content -path "C:\Users\enric.ferrer\Desktop\domain_admins.csv" -value ($admin.Name + ";" + $admin.DistinguishedName + ";" +$admin.SamAccountName)
}