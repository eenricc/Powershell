#MODULS
Import-Module ActiveDirectory
Import-module MSOnline
Import-Module ExchangeOnlineManagement

#VARIABLES
$LogDate = get-date -f dd/MM/yyyy
$LogDate30 = (get-date).AddDays(30)  
$LogDateBaja = Get-Date $LogDate30 -format dd/MM/yyyy
$Description = ("$LogDate Exit - $LogDateBaja Move to USERS OUT COMPANY")
$UserDisabled = "OU=-011 USERS OUT COMPANY,DC=cosentinogroup,DC=net"
$UserRedirected = "OU=-012 REDIRECTED USERS MAILBOX,DC=cosentinogroup,DC=net"
$DomainUsers = "Domain Users"
$ticket = ""
$logFile = "C:\scripts\BajaUsuarios\Log_BajaUsuario.csv"
$Admin = $(whoami)
$WhoAmI = $Admin.split("\")[1] + "@cosentino.com"
$loop = $true
$TryUser = $true

#ARXIU LOG
$logfilePath = (Test-Path $logFile)
If (($logFilePath) -ne "True") {
    New-Item $logfile -ItemType File
    Add-Content $logfile "Admin,UserName,Date"
}

#FUNCIONS
Function DeshabilitaUser ($DeshabilitaUser){
    Set-ADUser $DeshabilitaUser -Enabled $false 
    Write-Host "USUARIO DESHABILITADO - USER DISABLED" -foregroundcolor "yellow"
}

Function DeshabilitaAcces ($DeshabilitaAcces){
    Set-CASMailbox -Identity $DeshabilitaAcces.UserPrincipalName -ActiveSyncEnabled $false 
    Set-CASMailbox -Identity $DeshabilitaAcces.UserPrincipalName -OWAEnabled $false 
    Set-CASMailbox -Identity $DeshabilitaAcces.UserPrincipalName -PopEnabled $false 
    Set-CASMailbox -Identity $DeshabilitaAcces.UserPrincipalName -ImapEnabled $false 
}

<#
Function ComprovaLlicencies ($ComprovaLlicencies){
    $NewE3 = "grupocosentino:SPE_E3"
    $NewE5 = "grupocosentino:SPE_E5"
    $NewF3 = "grupocosentino:SPE_F1"
    $NewExchArc = "grupocosentino:EXCHANGEARCHIVE_ADDON"
    $Licencia = Get-MsolUser -UserPrincipalName $ComprovaLlicencies.UserPrincipalName | Select-Object -ExpandProperty Licenses

    $NoTiene = $true
    If ($Licencia | ? {$_.AccountSkuId -eq $NewE3}){$Global:licenciaactiva = $Licencia.AccountSkuId | ? {$_ -ne $NewE3}; $NoTiene = $false }
    If ($Licencia | ? {$_.AccountSkuId -eq $NewE5}){$Global:licenciaactiva = $Licencia.AccountSkuId | ? {$_ -ne $NewE5}; $NoTiene = $false }
    If ($Licencia | ? {$_.AccountSkuId -eq $NewF3}){$Global:licenciaactiva = $Licencia.AccountSkuId | ? {($_ -ne $NewF3) -and ($_ -ne $NewExchArc)}; $NoTiene = $false }
    If ($NoTiene) {$Global:licenciaactiva = $Licencia.AccountSkuId}
}
#>

Function OcultaLlista ($OcultaLlista){
    Set-ADUser $OcultaLlista -Replace @{msExchHideFromAddressLists = $true}
    Write-Host "ATRIBUTO msExchHideFromAddressLists CAMBIADO A TRUE - USER HIDDEN IN GAL" -foregroundcolor "yellow"
}

Function AddDescripcio($AddDescUser,$AddDesc){
    Set-ADUser $AddDescUser -Replace @{description = $AddDesc}
    Write-Host "DESCRIPCCIÓN COMPLETADA: $AddDesc" -foregroundcolor "yellow"
}

Function GrupDomUser ($GrupDomUser){
    $Global:SAMAccountName = $GrupDomUser.SAMAccountName
    $NewPrimaryGroupToken = (Get-ADGroup $DomainUsers -Properties primaryGroupToken).primaryGroupToken
    Get-ADUser $Global:SAMAccountName | Set-ADObject -Replace  @{primaryGroupID=$NewPrimaryGroupToken}
    Write-Host "GRUPO PRINCIPAL CAMBIADO A $DomainUsers " -foregroundcolor "yellow"
}

Function BackupGrups ($BackupGrups){
    $grups = Get-ADPrincipalGroupMembership $BackupGrups | select name
    $text = ""
    foreach ($grup in $grups) {
        $text = $text + "$grup, " -replace ("@{name=","") -replace ("}","")
    }
    Set-ADUser $BackupGrups -replace @{adminDescription="$text"}
    Write-Host "BACKUP DE GRUPOS EN ADMINDESCRIPTION DEL USUARIO $Global:SAMAccountName " -foregroundcolor "yellow"
}

Function DelGrups ($DelGrups){
    $userGroups = $DelGrups.memberof
    $userGroups | %{get-adgroup $_ | Remove-ADGroupMember -confirm:$false -member $Global:SAMAccountName}
    $userGroups = $null
    Write-Host "GRUPOS ELIMINADOS DEL USUARIO $Global:SAMAccountName " -foregroundcolor "yellow"
}

Function DelAtributs ($DelAtributs){
    Set-ADObject $DelAtributs -Clear extensionAttribute1, extensionAttribute2, extensionAttribute3, extensionAttribute4, extensionAttribute5
    Set-ADObject $DelAtributs -Clear extensionAttribute6, extensionAttribute7, extensionAttribute8, extensionAttribute9, extensionAttribute10
    Set-ADObject $DelAtributs -Clear extensionAttribute11, extensionAttribute12, extensionAttribute13, extensionAttribute14, extensionAttribute15
    Set-ADObject $DelAtributs -Clear telephoneNumber, mobile, ipPhone, facsimileTelephoneNumber, otherTelephone, pager, company, title
    Set-ADObject $DelAtributs -Clear otherFacsimileTelephoneNumber, otherHomePhone, otherIpPhone, otherMobile, otherPager, telephoneAssistant, info
    Set-ADObject $DelAtributs -Clear postOfficeBox, postalAddress, languageCode, homePhone, homePostalAddress
    Set-ADObject $DelAtributs -Clear manager
    Write-Host "ATRIBUTOS LIMPIOS " -foregroundcolor "yellow"
}

Function MouRedirected ($MouRedirected){
    $userDN = $MouRedirected.DistinguishedName
    Move-ADObject -Identity $userDN -TargetPath $UserRedirected
    Write-Host "USUARIO MOVIDO A -012 REDIRECTED USERS MAILBOX" -foregroundcolor "yellow"
}

Function DelRedireccio ($DelRedireccio){
    Set-Mailbox -Identity $DelRedireccio.SamAccountName -DeliverToMailboxAndForward $false -ForwardingSmtpAddress $null -ForwardingAddress $null 
}

#SCRIPT PROCÉS BAIXA
While ($loop = $true){
    clear-host
    While ($TryUser -eq $true){
        Try{
            Write-host "NOMBRE DE USUARIO PARA LA BAJA: USERNAME FOR THE EXIT:" -ForegroundColor "yellow" -NoNewline
            $usuarioRead = Read-Host 
            $usuario = Get-ADUser $usuarioRead -Properties * -ErrorAction Stop
            $TryUser = $false
        } Catch {
            Write-Host "EL USUARIO NO EXISTE EN EL DOMINO - USER DOESNT EXIST IN DOMAIN" -ForegroundColor "red"
            $_.Exception.Messag
        } 
    }
    
    Write-host "USUARIO - USER: $($USUARIO.SAMACCOUNTNAME) - $($USUARIO.DisplayName)"
    Write-host "¿DESEA CONTINUAR? (Y/N) - ¿ARE YOUR SURE? (Y/N)" -ForegroundColor "yellow" -NoNewline
    $confirmacion = Read-Host

    If(($confirmacion -ne "Y") -or ($confirmacion -ne "y")) { 
        Exit
    }
  
    #CONEXIÓ AZURE AD
    Connect-MsolService

    #CONNEXIÓ EXCHANGE 
    Write-Host "CONECTANDO CON EXCHANGE ONLINE..." -foregroundcolor "Green"
    Connect-ExchangeOnline -ShowBanner:$false -UserPrincipalName $WhoAmI #-ConnectionUri "https://outlook.office365.com/powershell-liveid/"

    #Deshabilita user
    DeshabilitaUser $usuario
        
    #Canvi atribut perque no es mostri user a llista de contactes
    OcultaLlista $usuario

    #Grup Domain Users com a principal d'usuari
    GrupDomUser $usuario
        
    #Copia de seguretat dels grups actuals a AdminDescription
    BackupGrups $usuario

    #Es treuen tots els grups al usuari
    DelGrups $usuario
    
    #Es borren els extensionAttibutes / Es mante ID empleat al camp wWWHomePage
    DelAtributs $usuario

    <#
    #Comprova i recupera llicencies actives
    ComprovaLlicencies $usuario
    #>

    Write-Host "¿SE HA SOLICITADO AUTORESPUESTA EN EL CORREO?(Y/N) - EMAIL AUTOREPLY REQUIRED? (Y/N)"-ForegroundColor "yellow" -NoNewline 
    $autoreplay = Read-Host

    If(($autoreplay -eq "N") -or ($autoreplay -eq "n")){
        
        #Afegim camp Descripcio
        AddDescripcio $usuario $description
  
        #Configuracio MailTip per informar que no existeix bustia 
        Write-Host "ESTABLECIENDO MAILTIP..." -ForegroundColor Yellow
        Set-Mailbox $usuario.UserPrincipalName -MailTip "Esta cuenta ya no está activada / This account is no longer activated." 
    }

    If(($autoreplay -eq "Y") -or ($autoreplay -eq "y")){
        Write-Host "INTRODUCE LA DIRECCIÓN DE EMAIL COMPLETA PARA AUTORESPUESTA - PUT WHOLE EMAIL ADDRESS TO AUTOREPLY: " -foregroundcolor "yellow" -NoNewline
        $forwarding = Read-Host 
           
        <#
        #Treu la llicencia actual
        Set-MsolUserLicense -UserPrincipalName $usuario.UserPrincipalName -RemoveLicenses $licenciaactiva
        #>

        #Activar Autoresposta
        $TextDN = $usuario.Name
        $Message = "<html><head>
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
    
        Set-MailboxAutoReplyConfiguration -Identity $usuario.SamAccountName -AutoReplyState Enabled -InternalMessage $Message -ExternalMessage $Message

        Write-Host "LA REDIRECCION DE CORREO HA DE SER APROBADA POR COMITE DE ETICA - THE MAIL FORWARD MUST BE APPROVED BY THE ETHICS COMMITTEE" -ForegroundColor "Yellow"
        Write-Host "¿SE HA SOLICITADO REDIRECCIÓN DEL CORREO?(Y/N) - EMAIL FORWARD REQUIRED? (Y/N)"-ForegroundColor "yellow" -NoNewline 
        $redireccion = Read-Host 
        
        #Afegim informació al camp descripció
        If(($redireccion -eq "Y") -or ($redireccion -eq "y")){
            Write-Host "INTRODUZCA ID TICKET DE AUTORIZACIÓN "-ForegroundColor "yellow" -NoNewline 
            $ticket = Read-host   
            Write-Host "INTRODUCE LA DIRECCIÓN DE EMAIL COMPLETA DONDE SE REDIRECCIONA - PUT WHOLE EMAIL ADDRESS WHERE TO FORWARD: " -foregroundcolor "yellow" -NoNewline
            $emailForwarding = Read-Host 
            $DescriptionForward = "$LogDate Exit - $LogDateBaja Move to OUT OF COMPANY. Forwarding to $emailForwarding ticket $ticket and AutoReply to $forwarding"
            #Assignar Redirecció
            Set-Mailbox -Identity $usuario.SamAccountName  -ForwardingAddress $emailForwarding -ForwardingSmtpAddress $emailForwarding -DeliverToMailboxAndForward $true -Confirm:$false            
            Write-Host "EMAIL REDIRECCIONADO A - EMAIL FORWARD TO: $emailForwarding " -foregroundcolor "yellow" -NoNewline
        }else{
            $DescriptionForward = "$LogDate Exit - $LogDateBaja Move to OUT OF COMPANY. AutoReply to $forwarding"
        }
                
        AddDescripcio $usuario $DescriptionForward
    }

    #Mou user a -012 REDIRECTED USERS MAILBOX
    MouRedirected $usuario
        
    #Deshabilita acces a  la bustia a dispositius mobils
    DeshabilitaAcces $usuario
          
    #Eliminar redirecció de correu activa
    DelRedireccio $usuario

    #Afegeix info al LOG
    Add-Content $logfile "$admin,$usuario.SamAccountName,$LogDate" 

    Write-Host "¿REALIZAR OTRA BAJA?(Y/N) - DO ANOTHER EXIT (Y/N)"-ForegroundColor "yellow" -NoNewline 
    $otra = Read-Host 

    If (($otra -eq "N") -or ($otra -eq "n")) {
        $loop = $false
        Write-Host "SINCRONIZANDO CON 365......SYNCHRONIZING WITH 365......"  -foregroundcolor "yellow"
        Start-ADSyncSyncCycle -PolicyType Delta | Out-Null
        exit
    }
}