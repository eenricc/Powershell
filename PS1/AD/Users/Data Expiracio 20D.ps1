#DADES DEL SEVIDOR DE CORREU
$smtpServer="172.29.3.13"
$from = "COSENTINO PASSWORD <helpdesk@cosentino.com>"
$Subject = "Account about to expire / Cuenta a punto de expirar"
$emailaddress = "enric.ferrer@t-systems.com"
$textEncoding = [System.Text.Encoding]::UTF8


#COMPTES EXPIRATS O QUE EXPIREN EN 20D
$Users = Search-ADAccount -SearchBase "OU=07 EXTERNAL USERS,OU=-001 COSENTINO USERS,DC=cosentinogroup,DC=net" -AccountExpiring -TimeSpan 20.00:00:00 

#EXTRACCIÓ D'USUARIS I ELS SEUS MANAGERS (EL CAMP MANAGER HA D'ESTAR OMPLERT)
ForEach ($User in $Users){
    $Prop = Get-Aduser $User -Properties * |Select-Object Name, AccountExpirationDate, EmailAddress, Manager        
    
    If ($prop.Manager -ne $null) { 
        $Manager = $Prop.Manager
        $email = Get-Aduser $Manager -Properties * |Select-Object EmailAddress, Name
        $NombreUsuario = $user.Name
        $NombreManager = $email.name
        $Expiracion = $Prop.AccountExpirationDate
        $emailaddress = $email.EmailAddress 
        $body ="
        Dear $NombreManager,
        <p> The $NombreUsuario account will expire $Expiracion<br>  
        Please open a ticket to helpdesk indicating if the account must be cancelled or, if it's still in use, please indicate a new expiration date.
        </P>
        
        Hola $NombreManager,
        <p> La cuenta de $NombreUsuario caducará el $Expiracion<br>  
        Por favor, abra un ticket a Helpdesk indicando si la cuenta se cancelará o, en caso de mantenerse, indicar una nueva fecha de expiración.
        </P>

        <p>Regards/Saludos</p>
        "
        #Write-Host "Manager: " $NombreManager
        #Write-Host "Usuario: " $NombreUsuario
        #Write-Host "Expiracion: " $Expiracion
        #ENVIEM CORREU
        Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -priority High -Encoding $textEncoding   
    }
}







