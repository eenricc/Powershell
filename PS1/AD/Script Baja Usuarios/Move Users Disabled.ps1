#VERIFICA DATA ACTUAL
$Data_move = ""
$Data = Get-Date
$DataLog = Get-Date -Format ddMMyyyy
$LogFile = "C:\ts_data\MWS\Scripting\MoveUsersDisabled\Move_Users_Disabled_$DataLog.csv"

#FUNCIO LOG
Function EscriuLog ($LOGInfo) {    
    Add-content -Path $LogFile -Value $LOGInfo
}

EscriuLog "NAME;SAMACCOUNT;DESCRIPCION;MOVIMENTO"

#CERCA USUARI
$users = Get-ADUser -filter * -Properties * -SearchBase "OU=-012 REDIRECTED USERS MAILBOX,DC=cosentinogroup,DC=net"

ForEach ($user in $users){
    $descripcio = $user.Description
    $Data_desc= $descripcio.substring(18,10)
    
    #VERIFICACIO DATA INFORMADA AMB SCRIPT DE BAIXES
    If ($Data_desc -like "??/??/????"){
        $Data_move = get-date ($data_desc) 
        #Write-Host $user.SamAccountName "- Data Format Correcte"

        #COMPAREM DATES
        If ($data_move -lt $Data){
            #Write-Host $user.SamAccountName "- Es mou"
            EscriuLog ($user.cn + ";" +$user.SamAccountName + ";" + $user.Description + ";Si")
            Move-ADobject -Identity $user.DistinguishedName -TargetPath "OU=-011 USERS OUT COMPANY,DC=cosentinogroup,DC=net"

        }Else{
            #Write-Host $user.SamAccountName "- Encara no es pot moure"
            #EscriuLog ($user.cn + ";" +$user.SamAccountName + ";" + $user.Description + ";No")

        }    
    }Else{
        #Write-Host $user.SamAccountName "- Data format incorrecte" -ForegroundColor Red
        EscriuLog ($user.cn + ";" +$user.SamAccountName + ";" + $user.Description + ";Formato fecha no reconocido")
    }
}



    