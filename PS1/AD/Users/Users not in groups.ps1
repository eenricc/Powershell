
$group1 = get-adgroup "mfa_trusted_pilot"
$group2 = get-adgroup "001 Cosentino USERS - MFA"
$group3 = get-adgroup "Carga Masiva MFA"
$group4 = get-adgroup "Comité ejecutivo MFA"
$group5 = get-adgroup "Externos" 

$dades = Get-aduser -Properties cn,memberof -filter 'enabled -eq $true' -SearchBase "OU=-001 COSENTINO USERS,DC=cosentinogroup,DC=net"| Where-Object {($_.DistinguishedName -notlike "*OU=VIPs*") -and ($group1.DistinguishedName -notin $_.memberof) -and ($group2.DistinguishedName -notin $_.memberof) -and ($group3.DistinguishedName -notin $_.memberof) -and ($group4.DistinguishedName -notin $_.memberof) -and ($group5.DistinguishedName -notin $_.memberof)}
Foreach ($usuari in $dades){
    add-content -Path "c:\users\enric.ferrer\desktop\MFA.csv" -value ($usuari.cn + ";" + $usuari.DistinguishedName)
}