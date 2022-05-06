#DADES DEL SEVIDOR DE CORREU
$smtpServer="172.29.3.13"
$from = "COSENTINO MFA <helpdesk@cosentino.com>"
$Subject = "Usuarios nuevos sin grupo MFA"
$textEncoding = [System.Text.Encoding]::UTF8
$body = "
Hola,
<p>
Se adjuntan el listado de usuarios nuevos a los que no se ha añadido el grupo de MFA.
<p>
Saludos,
"

#DADES MFA
$data = get-date -Format ddMMyy
$Arxiu = "C:\ts_data\mws\Scripts\MFA\MFA_$data.csv"
$group1 = get-adgroup "mfa_trusted_pilot"
$group2 = get-adgroup "001 Cosentino USERS - MFA"
$group3 = get-adgroup "Carga Masiva MFA"
$group4 = get-adgroup "Comité ejecutivo MFA"
$group5 = get-adgroup "Externos" 

$dades = Get-aduser -Properties cn,memberof -filter 'enabled -eq $true' -SearchBase "OU=-001 COSENTINO USERS,DC=cosentinogroup,DC=net"| Where-Object {($_.DistinguishedName -notlike "*OU=VIPs*") -and ($group1.DistinguishedName -notin $_.memberof) -and ($group2.DistinguishedName -notin $_.memberof) -and ($group3.DistinguishedName -notin $_.memberof) -and ($group4.DistinguishedName -notin $_.memberof) -and ($group5.DistinguishedName -notin $_.memberof)}
Foreach ($usuari in $dades){
    add-content -Path $arxiu -value ($usuari.cn + ";" + $usuari.DistinguishedName)
}

#Verifica si existeix arxiu
$Existeix = Test-Path -Path $Arxiu

If ($Existeix -eq $True){
    $ArxiuContingut = Get-Content $Arxiu
    If (!($ArxiuContingut -eq $Null)){
        Send-Mailmessage -smtpServer $smtpServer -from $from -to 'enric.ferrer@t-systems.com' -subject $subject -body $body -bodyasHTML -priority High -Encoding $textEncoding -Attachments "c:\ts_data\mws\scripts\mfa\MFA_$data.csv"
    }
}

