#AL CSV NECESITEM COLUMNA: TextBoxUser ; TextboxPassword
$user = Import-Csv "c:\users\enric.ferrer\desktop\1.csv" -Delimiter ";" #DESAR EN UTF-8

Foreach ($usuario in $user){
   
    $hash = @{
    Name = $usuario.TextBoxUser + " Fabrica"
        Displayname = $usuario.TextBoxUser + " Fabrica"
        Path = "OU=Fabrica,OU=GENERIC,OU=-020 OTHER USERS,DC=cosentinogroup,DC=net"
        Surname = "Fabrica"
        GivenName = $usuario.TextBoxUser
        Samaccountname = $usuario.TextBoxUser
        UserPrincipalName = $usuario.TextBoxUser + "@cosentino.com"
        AccountPassword = ConvertTo-SecureString -String $usuario.TextboxPassword -AsPlainText -Force 
        Enabled = $True
        ChangePasswordAtLogon = $False
        Description = "Usuario generico de Fabrica"
    }
     
    
        New-ADUser @hash -PassThru -PasswordNeverExpires $True | Out-Null 
        Add-ADGroupMember -Identity "AccesoBasico" -Members $usuario.TextBoxUser
        Add-ADGroupMember -Identity "InternetAccess-N0" -Members $usuario.TextBoxUser
        Add-ADGroupMember -Identity "Usuarios_Terminales" -Members $usuario.TextBoxUser
}
        
  
