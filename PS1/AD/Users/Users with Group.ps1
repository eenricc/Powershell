$usuaris = get-aduser -Properties * -Filter * -SearchBase "OU=-001 COSENTINO USERS,DC=cosentinogroup,DC=net"| Where-Object {($_.DistinguishedName -notlike "*OU=VIPs*")} 
#$usuaris = get-aduser -Properties * -Filter * -SearchBase "OU=Workplace,OU=T-System,OU=EXTERNAL,OU=07 EXTERNAL USERS,OU=-001 COSENTINO USERS,DC=cosentinogroup,DC=net"

foreach ($usuari in $usuaris) {
    $GrupMFA = Get-ADPrincipalGroupMembership $usuari | Where {$_.name -like "001 Cosentino USERS - MFA"}
    If ($GrupMFA){
        add-content -Path "c:\users\enric.ferrer\desktop\MFA_Enric.csv" -value ($usuari.cn + ";" + $usuari.DistinguishedName + ";" + "Tiene el grupo")
    }Else{
        add-content -Path "c:\users\enric.ferrer\desktop\MFA_Enric.csv" -value ($usuari.cn + ";" + $usuari.DistinguishedName + ";" + "NO Tiene el grupo")
    }
}

    