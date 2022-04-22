# VARIABLES
$OU = "OU=Fabrica,OU=GENERIC,OU=-020 OTHER USERS,DC=cosentinogroup,DC=net"
#CSV necesita columnes: Samaccountname;GivenName;Surname;description;password
$ArxiuCSV = "C:\Users\enric.ferrer\Desktop\Scripts\AD New Users Massive.csv" #DESAR EN UTF-8
$Domain = "@cosentino.com"
$GroupName = "AccesoBasico"
$GroupName2 = "InternetAccess-N0"
$GroupName3 = "Usuarios_Terminales"

# SCRIPT
$Users = Import-Csv -Delimiter ";" -Path "$ArxiuCSV"

foreach ($User in $Users) {   
    
    $hash = @{
        Name = $user.givenname + " " + $user.Surname 
        Displayname = $user.givenname + " " + $user.Surname 
        Path = $OU
        Surname = $user.Surname
        GivenName = $user.givenName
        Samaccountname = $user.sAMAccountName
        UserPrincipalName = $user.sAMAccountName + $Domain
        AccountPassword = ConvertTo-SecureString -String $user.password -AsPlainText -Force 
        Enabled = $True
        ChangePasswordAtLogon = $False
        #Title = $user.title
	    #Company = $user.company
	    #City = $user.city
	    #MobilePhone = $user.mobile
        #Department = $user.Department  
        #HomePage = $user.wWWHomePage  
        Description = $user.description
        #EmployeeID = $user.EmployeeID
        #employeeNumber = $user.employeeNumber            
    } 
    Try{
        New-ADUser @hash -PassThru -PasswordNeverExpires $True | Out-Null
        Write-Host "Creat usuari" $user.GivenName $user.Surname -ForegroundColor "Green"
    }Catch{
        Write-Host "Error al crear usuari" $user.GivenName $user.Surname -ForegroundColor "Red"
    }
    
    #AFEGIR GRUP AL MEMBER OF DEL USUARI CREAT
    $UsuariNom = $user.sAMAccountName
    $UsuariAD = Get-ADUser -Filter {SamAccountName -eq $UsuariNom}
    Try {
        Add-ADGroupMember -Identity $GroupName -Members $UsuariAD
        Add-ADGroupMember -Identity $GroupName2 -Members $UsuariAD
        Add-ADGroupMember -Identity $GroupName3 -Members $UsuariAD
        Write-Host "Afegit usuari" $user.GivenName $user.Surname "als grups indicats" -ForegroundColor "Green"
        Write-Host "-----------------------------"
    }catch{
        Write-Host "NO S'ha afegit usuari" $user.GivenName $user.Surname "als grups indicats" -ForegroundColor "Red"
        Write-Host "-----------------------------"
        
    }
    
} 