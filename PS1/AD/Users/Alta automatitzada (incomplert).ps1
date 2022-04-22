Function CreaUsuari {
    $hash = @{
        Name = $Nombre + " " + $apellidos
        GivenName = $Nombre
        Surname = $Apellidos
        Displayname = $Nombre + " " + $Apellidos
        Path = "CN=Users,DC=cosentinogroup,DC=net"
        Samaccountname = $UID
        UserPrincipalName = $UID + "@cosentino.com"
        AccountPassword = ConvertTo-SecureString -String $PSWrandom -AsPlainText -Force 
        Enabled = $True
        ChangePasswordAtLogon = $False
        Description = $descripcion
        EMail = $email
        HomePage = $homepage
    }
     
    Try {
        New-ADUser @hash -PassThru -PasswordNeverExpires $False | Out-Null
        #Add-ADGroupMember -Identity "AccesoBasico" -Members $TextBoxUser.Text
        Write-Host "Usuario creado con los siguientes datos:"
        Write-Host "Nombre: $Nombre"
        Write-Host "Apellidos: $Apellidos"
        Write-Host "Usuario: $UID"
        Write-Host "Password: $PSWrandom"
        Write-Host "Descripcion: $Descripcion"
        Write-Host "E-Mail: $email"
        Write-Host "Homepage: $homepage"
        Write-Host "OU de destino: CN=Users,DC=cosentinogroup,DC=net"
                
       
    } catch {
        Write-Host "Error. Revisa que los campos introducidos son correctos o que no estan vacios y que el UID indicado no existe en el sistema"
        
    }
}

$majuscules = Get-Random -InputObject ([char[]] (([char] 'A')..([char] 'Z'))) -count 4 
$minuscules = Get-Random -InputObject ([char[]] (([char] 'a')..([char] 'z'))) -count 4 
$numeros = Get-Random -InputObject (('0')..('9')) -count 2
$PSWrandom = -join ($majuscules + $minuscules + $numeros)

Write-Host "CREACION DE USUARIOS v1.0:"
$Nombre = Read-Host "Introduce Nombre: "
$Apellidos = Read-Host "Introduce Apellidos: "
$UID = Read-Host "Introduce UID (nombre.apellido): "
Write-Host "Password Aleatorio: $PSWrandom" 
$Descripcion = Read-Host "Introduce descripcion: "
$email = Read-Host "Introduce e-mail: "
$homepage = Read-Host "Introduce Web (p.e. EXTERNO): "

CreaUsuari


