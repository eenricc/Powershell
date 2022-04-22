[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

##################### FORMULARI XAML #####################

[xml]$XAMLCode = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Alta AD" Height="185.427" Width="302.513" ResizeMode="CanMinimize">
    <Grid>
        <Button Name="ButtonUser" Content="Verifica" VerticalAlignment="Top" Margin="180,26,0,0" Height="23" HorizontalAlignment="Left" Width="75"/>
        <Button Name="ButtonPassword" Content="Password" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="180,63,0,0" Height="23" IsEnabled="False"/>
        <TextBox Name="TextboxUser" Height="23" TextWrapping="Wrap" VerticalAlignment="Top" Margin="47,26,0,0" HorizontalAlignment="Left" Width="120"/>
        <TextBox Name="TextboxPassword" HorizontalAlignment="Left" Height="23" TextWrapping="Wrap" VerticalAlignment="Top" Width="120" Margin="47,63,0,0" IsReadOnly="True"/>
        <Button Name="ButtonCrea" Content="Crea" VerticalAlignment="Top" Margin="100,103,0,0" HorizontalAlignment="Left" Width="102" IsEnabled="False"/>

    </Grid>
</Window>

"@

$Form=[Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $XAMLCode))

#VARIABLES FORMULARI
$XAMLCode.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name) }


##################### FUNCIONS #####################

Function GeneraPass {
    $majuscules = Get-Random -InputObject ([char[]] (([char] 'A')..([char] 'Z'))) -count 4 
    $minuscules = Get-Random -InputObject ([char[]] (([char] 'a')..([char] 'z'))) -count 4 
    $numeros = Get-Random -InputObject (('0')..('9')) -count 2
    $PSWrandom = -join ($majuscules + $minuscules + $numeros)
    $TextboxPassword.Text = $PSWrandom  
    $ButtonCrea.IsEnabled = $true
}

Function VerificaUser {
    If ($TextBoxUser.text -eq "") {
        [System.Windows.MessageBox]::Show("El campo usuario no puede estar vacío","Error","Ok","Error") | Out-Null
    } else {
        Try {
            Get-ADUser $TextBoxUser.text
            [System.Windows.MessageBox]::Show("Usuario indicado ya existe en AD","Error","Ok","Error") | Out-Null
        } Catch {
            [System.Windows.MessageBox]::Show("Usuario indicado correcto","Information","Ok","Information") | Out-Null
            $TextBoxUser.IsReadOnly = $true
            $ButtonPassword.IsEnabled = $true   
        }            
    }
}

Function CreaUsuari {
    $hash = @{
        Name = $TextBoxUser.Text + " Fabrica"
        Displayname = $TextBoxUser.Text + " Fabrica"
        Path = "OU=Fabrica,OU=GENERIC,OU=-020 OTHER USERS,DC=cosentinogroup,DC=net"
        Surname = "Fabrica"
        GivenName = $TextBoxUser.Text
        Samaccountname = $TextBoxUser.Text
        UserPrincipalName = $TextBoxUser.Text + "@cosentino.com"
        AccountPassword = ConvertTo-SecureString -String $TextboxPassword.Text -AsPlainText -Force 
        Enabled = $True
        ChangePasswordAtLogon = $False
        Description = "Usuario generico de Fabrica"
    }
     
    Try {
        New-ADUser @hash -PassThru -PasswordNeverExpires $True | Out-Null
        Add-ADGroupMember -Identity "AccesoBasico" -Members $TextBoxUser.Text
        Add-ADGroupMember -Identity "InternetAccess-N0" -Members $TextBoxUser.Text
        Add-ADGroupMember -Identity "Usuarios_Terminales" -Members $TextBoxUser.Text
        $ButtonPassword.IsEnabled = $False
        $ButtonCrea.IsEnabled = $false
        [System.Windows.MessageBox]::Show("Usuario dado de alta en la OU de Fabrica correctamente con los datos:`n`nUsuario: $($TextBoxUser.text)`nPassword: $($TextboxPassword.text)","Information","Ok","Information") | Out-Null
        $TextBoxUser.IsEnabled = $true
        $TextBoxUser.IsReadOnly = $false
        $TextBoxUser.Text = ""
        $TextboxPassword.Text = ""
    } catch {
        [System.Windows.MessageBox]::Show("Error desconocido al intentar crear usuario. Revisa los datos.","Error","Ok","Error") | Out-Null
    }
}

##################### ACCIONS BOTONS #####################
$ButtonUser.add_Click({VerificaUser})
$ButtonPassword.add_Click({GeneraPass})
$ButtonCrea.add_Click({CreaUsuari})


##################### MOSTRA FORMULARI #####################
$Form.ShowDialog() | Out-Null
  