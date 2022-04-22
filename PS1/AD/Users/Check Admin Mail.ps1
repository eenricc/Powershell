#DATOS SERVIDOR CORREO
$smtpServer="172.29.3.13"
$from = "COSENTINO ADMINS <helpdesk@cosentino.com>"
$Subject = "Usuarios Administradores"
$textEncoding = [System.Text.Encoding]::UTF8

$AdminValidados = @(
"TS_sysops",
"ts_backup",
"backup",
"TS_Operaciones",
"TS_WINTEL",
"admfactoryms",
"Administrator",
"Enterprise Admins",
"Domain Admins"
)
$DomAdminValidados = @(
"Administrator",
"DomAdmin-TSystems",
"m.mmembrive",
"srvmicrosoft",
"wvd_prueba",
"v.resina",
"a.romo",
"d.moreno"
)

Clear-Variable AlertaAdmin -ErrorAction SilentlyContinue
Clear-Variable AlertaDomAdmin -ErrorAction SilentlyContinue

$admin = (Get-ADGroupMember "Administrators").samaccountname
$domAdmin = (Get-ADGroupMember "Domain Admins").samaccountname

#BUSCAMOS USUARIOS ADMIN QUE NO PERTENEZCAN AL GRUPO CONTROLADO
Foreach ($userAdmin in $admin){
    If (!($AdminValidados -match $userAdmin)){
        #write-host $userAdmin -ForegroundColor Red
        $AlertaAdmin += "$userAdmin "
    }
}

#BUSCAMOS USUARIOS DOMAINADMIN QUE NO PERTENEZCAN AL GRUPO CONTROLADO
Foreach ($userDomainAdmin in $domAdmin){
    If (!($DomAdminValidados -match $userDomainAdmin)){
        #write-host $userDomainAdmin -ForegroundColor Red
        $AlertaDomAdmin += "$userDomainAdmin "
    }
}

#EN CASO QUE NO HAYA USUARIOS ADMIN NUEVOS
If ($AlertaAdmin -eq $Null -and $AlertaDomAdmin -eq $Null) {
    #Write-Host "No existen usuarios no controlados en el grupo Administrators / Domain Admins"
} Else {  
    #Write-Host "Existen usuarios no controlados en el grupo Administrators / Domain Admins" -ForegroundColor Red
    $body = "
        Hola,
        <p>
        Se ha detectado usuario/s que no deben pertenecer a alguno de los grupos Administrators/Domain Admins. <br>
        <p>
        <u>Usuarios detectados en Administrators:</u><br> 
        $AlertaAdmin
        <p>
        <u>Usuarios detectados en Domain Admins:</u><br> 
        $AlertaDomAdmin
        <p>
        <p>
        Saludos
        "
    Send-Mailmessage -smtpServer $smtpServer -from $from -to 'enric.ferrer@t-systems.com','alberto.gil@t-systems.com','alejandro.salas@t-systems.com' -subject $subject -body $body -bodyasHTML -priority High -Encoding $textEncoding      
    
}     



    

