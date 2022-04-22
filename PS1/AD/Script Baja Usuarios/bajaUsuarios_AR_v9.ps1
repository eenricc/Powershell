#llamada a script para la funcion de conexión a 365
. C:\scripts\connect365.ps1

#llamada al modulo para Directorio Activo
Write-Host "CONECTANDO CON AD.......CONNECTING WITH AD...." -foregroundcolor "yellow"

#Importa comandos de Azuera

#creación de variables
$LogDate = get-date -f dd/MM/yyyy
$LogDate30 = (get-date).AddDays(30)  
$LogDateBaja = Get-Date $LogDate30 -format dd/MM/yyyy
$Description = ("$LogDate Exit - $LogDateBaja Move to USERS OUT COMPANY")
#usuarios fuera de la compañia sin licenciamiento activo en O365
$UserDisabled = "OU=-011 USERS OUT COMPANY,DC=cosentinogroup,DC=net"
$UserDisabled_prov = "OU=-012 REDIRECTED USERS MAILBOX,DC=cosentinogroup,DC=net"
#usuarios fuera de la compañia con liciencia de correo activa para AutoRespuesta o Redirección
$UserRedirected = "OU=-012 REDIRECTED USERS MAILBOX,DC=cosentinogroup,DC=net"
#grupo por defecto que ha de quedar una vez limpiado el objeto usuario
$DomainUsers = "Domain Users"
#info Ticket
$ticket = ""
#registro de logs
$logFile = "C:\scripts\BajaUsuarios\log.csv"
#identificacion de operador
$Admin = $(whoami)

#creación de fichero de log si es necesario
$logfilePath = (Test-Path $logFile)
if (($logFilePath) -ne "True")
 {
        # Create CSV File and Headers
        New-Item $logfile -ItemType File
        Add-Content $logfile "Admin,UserName,Date"
 }

 
##############################################
#liberamos sesiones antes de conectar con 365#
##############################################
Get-PSSession | Remove-PSSession



#$usuario, varieable para almacenar el nombre de usuario para dar de baja
#solicitamos el user name para la baja
Import-Module ActiveDirectory
Import-module MSOnline
#Connecta a AZure AD
Write-Host "CONECTANDO CON 365......CONNECTING 365...." -foregroundcolor "yellow"
#connect365
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Write-Host "........................" -foregroundcolor "green"
365Licenses_
#Connect-MsolService -Credential $UserCredential


###################
##PROCESO DE BAJA##
###################

$loop = $true
While ($loop =$true){
clear-host
Write-host "####################################################################" -foregroundcolor "green"
Write-host "#                                                                  #" -foregroundcolor "green"
Write-host "#                 SCRIPT BAJA COSENTINO                            #" -foregroundcolor "green"
Write-host "#                                                                  #" -foregroundcolor "green"
Write-host "####################################################################" -foregroundcolor "green"


Try{
Write-host ""
Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
Write-host "NOMBRE DE USUARIO PARA LA BAJA: USERNAME FOR THE EXIT:" -ForegroundColor "yellow" -NoNewline
$usuario = Read-Host 
$usuario = Get-ADUser $usuario -Properties * -ErrorAction Stop
}

Catch {
Write-Host "EL USUARIO NO EXISTE EN EL DOMINO - USER DOESNT EXIST IN DOMAIN" -ForegroundColor "red"
$_.Exception.Message
pause
exit
}

Write-host ""
Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
Write-host "USUARIO - USER: $($USUARIO.SAMACCOUNTNAME) - $($USUARIO.DisplayName)"
Write-host "¿DESEA CONTINUAR? (Y/N) - ¿ARE YOUR SURE? (Y/N)" -ForegroundColor "yellow" -NoNewline
$confirmacion = Read-Host
if(($confirmacion -ne "Y") -or ($confirmacion -ne "y")){ Exit }

Write-Host "¿SE HA SOLICITADO AUTORESPUESTA EN EL CORREO?(Y/N) - EMAIL AUTOREPLY REQUIRED? (Y/N)"-ForegroundColor "yellow" -NoNewline 
$autoreplay = Read-Host 

Write-Host "LA REDIRECCION DE CORREO HA DE SER APROBADA POR COMITE.ETICA - THE MAIL FORWARD MUST BE APPROVED BY THE COMITE.ETICA " -ForegroundColor "red"
Write-Host "¿SE HA SOLICITADO REDIRECCIÓN DEL CORREO?(Y/N) - EMAIL FORWARD REQUIRED? (Y/N)"-ForegroundColor "yellow" -NoNewline 
$redireccion = Read-Host 

if(($redireccion -eq "Y") -or ($redireccion -eq "y")){
    Write-Host "INTRODUZCA ID TICKET DE AUTORIZACIÓN "-ForegroundColor "yellow" -NoNewline 
    $ticket = Read-host


    Write-Host "INTRODUCE LA DIRECCIÓN DE EMAIL COMPLETA DONDE SE REDIRECCIONA - PUT WHOLE EMAIL ADDRESS WHERE TO FORWARD: " -foregroundcolor "yellow" -NoNewline
    $emailForwarding = Read-Host 

}

if(($autoreplay -eq "N") -or ($autoreplay -eq "n")){
    #se deshabilita el usuario#
    Set-ADUser $usuario -Enabled $false 
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    Write-Host "USUARIO DESHABILITADO - USER DISABLED" -foregroundcolor "yellow"

    #se cambia el atributo para que no se muestre el usuario en la lista de contactos#
    Set-ADUser $usuario -Replace @{msExchHideFromAddressLists = $true}
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    Write-Host "ATRIBUTO msExchHideFromAddressLists CAMBIADO A TRUE - USER HIDDEN IN GAL" -foregroundcolor "yellow"

    #se añade informacion sobre la actuacion en el campo descripcion#
    Set-ADUser $usuario -Replace @{description = $Description}
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    Write-Host "DESCRIPCIÓN COMPLETADA: $Description" -foregroundcolor "yellow"

    #establecemos Domain Users como grupo principal para el usuario
    $SAMAccountName = $usuario.SAMAccountName
    $NewPrimaryGroupToken = (Get-ADGroup $DomainUsers -Properties primaryGroupToken).primaryGroupToken
    Get-ADUser $SAMAccountName | Set-ADObject -Replace  @{primaryGroupID=$NewPrimaryGroupToken}
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"    
    Write-Host "GRUPO PRINCIPAL CAMBIADO A $DomainUsers " -foregroundcolor "yellow"

    #copia de grupos en el atribuito adminDescription
    $grups = Get-ADPrincipalGroupMembership $usuario | select name
    $text = ""
    foreach ($grup in $grups) {$text = $text + "$grup, " -replace ("@{name=","") -replace ("}","")}
    Set-ADUser $usuario -replace @{adminDescription="$text"}
    
    #quitamos todos los grupos a los que pertenece el usuario
    $userGroups = $usuario.memberof

    $userGroups | %{get-adgroup $_ | Remove-ADGroupMember -confirm:$false -member $SAMAccountName}
    $userGroups = $null
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    Write-Host "GRUPOS ELIMINADOS DEL USUARIO $SAMAccountName " -foregroundcolor "yellow"

    #quitamos la información de los extensionAttibutes
    #Solo se mantiene el ID de empleado en el campo wWWHomePage
    Set-ADObject $usuario -Clear extensionAttribute1, extensionAttribute2, extensionAttribute3, extensionAttribute4, extensionAttribute5
    Set-ADObject $usuario -Clear extensionAttribute6, extensionAttribute7, extensionAttribute8, extensionAttribute9, extensionAttribute10
    Set-ADObject $usuario -Clear extensionAttribute11, extensionAttribute12, extensionAttribute13, extensionAttribute14, extensionAttribute15
    Set-ADObject $usuario -Clear telephoneNumber, mobile, ipPhone, facsimileTelephoneNumber, otherTelephone, pager, company, title
    Set-ADObject $usuario -Clear otherFacsimileTelephoneNumber, otherHomePhone, otherIpPhone, otherMobile, otherPager, telephoneAssistant, info
    Set-ADObject $usuario -Clear postOfficeBox, postalAddress, languageCode, homePhone, homePostalAddress
    Set-ADObject $usuario -Clear manager
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    Write-Host "ATRIBUTOS LIMPIOS " -foregroundcolor "yellow"

    #Mueve al usuario a la OU -012 REDIRECTED USERS MAILBOX
    $userDN = $usuario.DistinguishedName
    Move-ADObject -Identity $userDN -TargetPath $UserDisabled_prov
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    Write-Host "USUARIO MOVIDO A -012 REDIRECTED USERS MAILBOX" -foregroundcolor "yellow"
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    
    
    <# SE MOVERA DE FORMA MANUAL A LOS 30 DIAS DE LA BAJA SEGUN INDICACIONES DE CLIENTE
    #mueve al usuario a la OU usuarios fuera de oficina#
    $userDN = $usuario.DistinguishedName
    Move-ADObject -Identity $userDN -TargetPath $UserDisabled
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    Write-Host "USUARIO MOVIDO A -011 USERS OUT COMPANY" -foregroundcolor "yellow"
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    #>

    ############################################
    #comprueba si tiene licencia 365 el usuario#
    ############################################
    $msolUserPrincipalName = $usuario.UserPrincipalName
    $isLicensed = Get-MsolUser -UserPrincipalName $usuario.UserPrincipalName
    $Licencia = Get-MsolUser -UserPrincipalName $usuario.UserPrincipalName | Select-Object -ExpandProperty Licenses

    ########################################################
    #Deshabilitar el acceso al buzón a dispositivos moviles#
    ########################################################
    Set-CASMailbox -Identity $usuario.UserPrincipalName -ActiveSyncEnabled $false
    Set-CASMailbox -Identity $usuario.UserPrincipalName -OWAEnabled $false
    Set-CASMailbox -Identity $usuario.UserPrincipalName -PopEnabled $false
    Set-CASMailbox -Identity $usuario.UserPrincipalName -ImapEnabled $false

    ########################################################
    #Se configura el Mail tip  para informar de que ya no existe#
    ########################################################

    Set-Mailbox $usuario.UserPrincipalName -MailTip "Esta cuenta ya no está activada / This account is no longer activated."

     #comprueba y recupera las licencias activas
    $NewE3 = "grupocosentino:SPE_E3"
    $NewE5 = "grupocosentino:SPE_E5"
    $NewF3 = "grupocosentino:SPE_F1"
    $NewExchArc = "grupocosentino:EXCHANGEARCHIVE_ADDON"
    $msolUserPrincipalName = $usuario.UserPrincipalName
    $isLicensed = Get-MsolUser -UserPrincipalName $usuario.UserPrincipalName
    $Licencia = Get-MsolUser -UserPrincipalName $usuario.UserPrincipalName | Select-Object -ExpandProperty Licenses

    #comprueba que licencia tiene para no eliminar F3,E3,E5
    $NoTiene = $true
    If ($Licencia | ? {$_.AccountSkuId -eq $NewE3}){$licenciaactiva = $Licencia.AccountSkuId | ? {$_ -ne $NewE3}; $NoTiene = $false }
    If ($Licencia | ? {$_.AccountSkuId -eq $NewE5}){$licenciaactiva = $Licencia.AccountSkuId | ? {$_ -ne $NewE5}; $NoTiene = $false }
    If ($Licencia | ? {$_.AccountSkuId -eq $NewF3}){$licenciaactiva = $Licencia.AccountSkuId | ? {($_ -ne $NewF3) -and ($_ -ne $NewExchArc)}; $NoTiene = $false }
    If ($NoTiene) {$licenciaactiva = $Licencia.AccountSkuId}

    ##################################################
    #se liberan todas las licencias para este usuario#
    ##################################################
    #$licenciaactiva = $Licencia.AccountSkuId
    #Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    #Write-Host "ESTADO DE LA/LAS LICENCIA/S: LICENSES STATUS:" -foregroundcolor "yellow" -NoNewline
    #Write-Host  $isLicensed.isLicensed -foregroundcolor "green"
    #Write-Host "LICENCIA/S ACTIVA/S - ACTIVE LICENSES" -foregroundcolor "yellow"
    #Write-Host $licenciaactiva -foregroundcolor "green"
    #Set-MsolUserLicense -UserPrincipalName $usuario.UserPrincipalName -RemoveLicenses $licenciaactiva
    #Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    #Write-Host "LICENCIA/S LIBERADA/S - LICENSES DESASSIGNED"  -foregroundcolor "yellow"
    #$licenciaactiva = $Licencia.AccountSkuId
    #Write-Host $licenciaactiva -foregroundcolor "red"

    #################################################
    #eliminar cualquier redirección de correo activa#
    #################################################
    Set-Mailbox -Identity $usuario.SamAccountName -DeliverToMailboxAndForward $false -ForwardingSmtpAddress $null -ForwardingAddress $null

    #Out-File -FilePath $OutputFile -InputObject   -Encoding UTF8 -append 
    #Write-Host "SINCRONIZANDO CON 365......SYNCHRONIZING WITH 365......"  -foregroundcolor "yellow"

    $nombreuser = $usuario.SamAccountName
    Add-Content $logfile "$admin,$nombreuser,$LogDate" 
}

If(($autoreplay -eq "Y") -or ($autoreplay -eq "y")){

    Write-Host "INTRODUCE LA DIRECCIÓN DE EMAIL COMPLETA PARA AUTORESPUESTA - PUT WHOLE EMAIL ADDRESS TO AUTOREPLY: " -foregroundcolor "yellow" -NoNewline
    $forwarding = Read-Host 

    #se deshabilita el usuario#
    Set-ADUser $usuario -Enabled $false 
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    Write-Host "USUARIO DESHABILITADO - USER DISABLED" -foregroundcolor "yellow"

    Write-host "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" -foregroundcolor "blue"

    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    Write-Host "CAMBIANDO LICENCIA A F1 - CHANGING LICENSE TO F1" -foregroundcolor "yellow"


    #Deshabilitar el acceso al buzón a dispositivos moviles#
    Set-CASMailbox -Identity $usuario.UserPrincipalName -ActiveSyncEnabled $false
    Set-CASMailbox -Identity $usuario.UserPrincipalName -OWAEnabled $false
    Set-CASMailbox -Identity $usuario.UserPrincipalName -PopEnabled $false
    Set-CASMailbox -Identity $usuario.UserPrincipalName -ImapEnabled $false


    ############################################
    #Elimina todas las licencias excepto F3,E3,E5 y autoarchivado en caso de F3#
    ############################################

    #comprueba y recupera las licencias activas
    $NewE3 = "grupocosentino:SPE_E3"
    $NewE5 = "grupocosentino:SPE_E5"
    $NewF3 = "grupocosentino:SPE_F1"
    $NewExchArc = "grupocosentino:EXCHANGEARCHIVE_ADDON"
    $msolUserPrincipalName = $usuario.UserPrincipalName
    $isLicensed = Get-MsolUser -UserPrincipalName $usuario.UserPrincipalName
    $Licencia = Get-MsolUser -UserPrincipalName $usuario.UserPrincipalName | Select-Object -ExpandProperty Licenses

    #comprueba que licencia tiene para no eliminar F3,E3,E5
    $NoTiene = $true
    If ($Licencia | ? {$_.AccountSkuId -eq $NewE3}){$licenciaactiva = $Licencia.AccountSkuId | ? {$_ -ne $NewE3}; $NoTiene = $false }
    If ($Licencia | ? {$_.AccountSkuId -eq $NewE5}){$licenciaactiva = $Licencia.AccountSkuId | ? {$_ -ne $NewE5}; $NoTiene = $false }
    If ($Licencia | ? {$_.AccountSkuId -eq $NewF3}){$licenciaactiva = $Licencia.AccountSkuId | ? {($_ -ne $NewF3) -and ($_ -ne $NewExchArc)}; $NoTiene = $false }
    If ($NoTiene) {$licenciaactiva = $Licencia.AccountSkuId}

    #quita todas las licencias Excepto la Microsoft 365 que tenia
    Set-MsolUserLicense -UserPrincipalName $usuario.UserPrincipalName -RemoveLicenses $licenciaactiva

    #Oculta al usuario en la lista de contactos#
    Set-ADUser $usuario -Replace @{msExchHideFromAddressLists = $true}
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    Write-Host "ATRIBUTO msExchHideFromAddressLists CAMBIADO A TRUE - USER HIDDEN FROM GAL" -foregroundcolor "yellow"


    #se añade información en el campo descripcion
    if(($redireccion -eq "Y") -or ($redireccion -eq "y")){
        $DescriptionForward = "$LogDate Exit - $LogDateBaja Move to OUT OF COMPANY. Forwarding to $emailForwarding ticket $ticket and AutoReply to $forwarding"
    }else{
        $DescriptionForward = "$LogDate Exit - $LogDateBaja Move to OUT OF COMPANY. AutoReply to $forwarding"
    }

    Set-ADUser $usuario -Replace @{description = $DescriptionForward}
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    Write-Host "DESCRIPCCIÓN COMPLETADA: $DescriptionForward" -foregroundcolor "yellow"



    #establecemos Domain Users como grupo principal para el usuario
    $SAMAccountName = $usuario.SAMAccountName
    $NewPrimaryGroupToken = (Get-ADGroup $DomainUsers -Properties primaryGroupToken).primaryGroupToken
    Get-ADUser $SAMAccountName | Set-ADObject -Replace  @{primaryGroupID=$NewPrimaryGroupToken}
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"    
    Write-Host "GRUPO PRINCIPAL CAMBIADO A $DomainUsers " -foregroundcolor "yellow"

    #copia de grupos en el atribuito adminDescription
    $grups = Get-ADPrincipalGroupMembership $usuario | select name
    $text = ""
    foreach ($grup in $grups) {$text = $text + "$grup, " -replace ("@{name=","") -replace ("}","")}
    Set-ADUser $usuario -replace @{adminDescription="$text"}

    #quitamos todos los grupos a los que pertenece el usuario
    $userGroups = $usuario.memberof

    $userGroups | %{get-adgroup $_ | Remove-ADGroupMember -confirm:$false -member $SAMAccountName}
    $userGroups = $null
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    Write-Host "GRUPOS ELIMINADOS DEL USUARIO $SAMAccountName " -foregroundcolor "yellow"

    #quitamos la información de los extensionAttibutes
    #Solo se mantiene el ID de empleado en el campo wWWHomePage
    Set-ADObject $usuario -Clear extensionAttribute1, extensionAttribute2, extensionAttribute3, extensionAttribute4, extensionAttribute5
    Set-ADObject $usuario -Clear extensionAttribute6, extensionAttribute7, extensionAttribute8, extensionAttribute9, extensionAttribute10
    Set-ADObject $usuario -Clear extensionAttribute11, extensionAttribute12, extensionAttribute13, extensionAttribute14, extensionAttribute15
    Set-ADObject $usuario -Clear telephoneNumber, mobile, ipPhone, facsimileTelephoneNumber, otherTelephone, pager, company, title
    Set-ADObject $usuario -Clear otherFacsimileTelephoneNumber, otherHomePhone, otherIpPhone, otherMobile, otherPager, telephoneAssistant, info
    Set-ADObject $usuario -Clear postOfficeBox, postalAddress, languageCode, homePhone, homePostalAddress
    Set-ADObject $usuario -Clear manager
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    Write-Host "ATRIBUTOS LIMPIOS " -foregroundcolor "yellow"

    #Mueve al usuario a la OU -012 REDIRECTED USERS MAILBOX
    $userDN = $usuario.DistinguishedName
    Move-ADObject -Identity $userDN -TargetPath $UserDisabled_prov
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    Write-Host "USUARIO MOVIDO A -012 REDIRECTED USERS MAILBOX" -foregroundcolor "yellow"
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    
    <# SE MOVERA DE FORMA MANUAL A LOS 30 DIAS DE LA BAJA SEGUN INDICACIONES DE CLIENTE
    #se mueve el objeto a la ou correspondiente#
    $userDN = $usuario.DistinguishedName
    Move-ADObject -Identity $userDN -TargetPath $UserRedirected
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    Write-Host "USUARIO MOVIDO A -012 REDIRECTED USERS MAILBOX" -foregroundcolor "yellow"
    #>


    #########################
    #actiar la autorespuesta#
    #########################
    $TextDN = $usuario.Name

    #texto html
    $IntMessage = "<html><head>
    </head>
    <body>
    Estimado,<br>
    <p>Por la presente le comunicamos que el empleado <b>$TextDN</b> ya no trabaja en la compañía.<br>
    Por favor, para cualquier consulta destinada a esta persona, póngase en contacto con $forwarding
    <br>
    <br>
    Disculpen las molestinas <br>
    Atentamente,<br>
    Cosentino </p>
    <br>
    <br>
    <br>
    Dear,<br>
    <p>We hereby inform you that <b>$TextDN</b> is no longer working at the company. For any request please contact $forwarding
    <br>
    <br>
    We apologize for any inconvenience caused. <br>
    Yours sincerely,<br>
    Cosentino </p>
    </body>
    </html>"

    $ExtMessage = $IntMessage

    #comando
    Set-MailboxAutoReplyConfiguration -Identity $usuario.SamAccountName -AutoReplyState Enabled -InternalMessage $IntMessage -ExternalMessage $ExtMessage

    #####################################################################################################################################################
    #Set-Mailbox -Identity $usuario.SamAccountName  -ForwardingAddress $forwarding -ForwardingSmtpAddress $forwarding -DeliverToMailboxAndForward $true
    #Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"
    #Write-Host "EMAIL REDIRECCIONADO A - EMAIL FORWARD TO: " -foregroundcolor "yellow" -NoNewline
    #Write-host $forwarding  -foregroundcolor "green"
    #######################################################################################################################################################

    #################################################
    #eliminar cualquier redirección de correo activa#
    #################################################
    Set-Mailbox -Identity $usuario.SamAccountName -DeliverToMailboxAndForward $false -ForwardingSmtpAddress $null -ForwardingAddress $null



    ###################################################################################
    #
    #ACTIVAR EL FORWARD
    #
    ###################################################################################
    if(($redireccion -eq "Y") -or ($redireccion -eq "y")){

    Set-Mailbox -Identity $usuario.SamAccountName  -ForwardingAddress $emailForwarding -ForwardingSmtpAddress $emailForwarding -DeliverToMailboxAndForward $true -Confirm:$false
    Write-host "------------------------------------------------------------------" -foregroundcolor "yellow"

    Write-Host "EMAIL REDIRECCIONADO A - EMAIL FORWARD TO: " -foregroundcolor "yellow" -NoNewline
    Write-host $emailForwarding  -foregroundcolor "green"

    }





    $nombreuser = $usuario.SamAccountName
    Add-Content $logfile "$admin,$nombreuser,$LogDate" 



#Start-Sleep -s 10
}

Write-Host "¿REALIZAR OTRA BAJA?(Y/N) - DO ANOTHER EXIT (Y/N)"-ForegroundColor "yellow" -NoNewline 
$otra = Read-Host 

if (($otra -eq "N") -or ($otra -eq "n")) {
$otra = $null
}

if ($otra -eq $null){
$loop = $false
Write-Host "SINCRONIZANDO CON 365......SYNCHRONIZING WITH 365......"  -foregroundcolor "yellow"
&"C:\scripts\syncTask.cmd"
exit
}

}
