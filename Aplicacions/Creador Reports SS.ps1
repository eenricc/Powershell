## FORMULARI
Add-Type -AssemblyName PresentationFramework

############## GUI ##############

[XML]$XAMLCode = @"
<Window x:Name="MainWindow1" 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:Reports_Cosentino"
        Title="Creador de Reports v1" Height="197.583" Width="232.628" ResizeMode="NoResize">
    <Grid Margin="0,0,4,0">
        <Button x:Name="ButtonADComputers" Content="Export AD Computers" HorizontalAlignment="Left" VerticalAlignment="Top" Width="204" Margin="10,10,0,0"/>
        <Button x:Name="ButtonADUsers" Content="Export AD Users" HorizontalAlignment="Left" VerticalAlignment="Top" Width="204" Margin="10,35,0,0"/>
        <Button x:Name="ButtonADComputersIncorrect" Content="Export Computers OU Incorrecta" HorizontalAlignment="Left" VerticalAlignment="Top" Width="204" Margin="10,60,0,0"/>
        <Button x:Name="ButtonADUsersIncorrect" Content="Export Users OU Incorrecta" HorizontalAlignment="Left" VerticalAlignment="Top" Width="204" Margin="10,85,0,0"/>
        <Button x:Name="ButtonInactiveComputers" Content="Export Inactive Computers (90D)" HorizontalAlignment="Left" VerticalAlignment="Top" Width="204" Margin="10,110,0,0"/>
        <Button x:Name="ButtonDomainAdmins" Content="Export Domain Admins" HorizontalAlignment="Left" VerticalAlignment="Top" Width="204" Margin="10,135,0,0"/>

    </Grid>
</Window>
"@

## CARREGUEM FORMULARI
$Reader = (New-Object System.Xml.XmlNodeReader $XAMLCode)
$Window = [Windows.Markup.XamlReader]::Load($Reader)

#OBJECTES DEL FORMULARI
$ButtonADComputers = $window.FindName("ButtonADComputers")
$ButtonADUsers = $window.FindName("ButtonADUsers")
$ButtonADComputersIncorrect = $window.FindName("ButtonADComputersIncorrect")
$ButtonADUsersIncorrect = $window.FindName("ButtonADUsersIncorrect")
$ButtonInactiveComputers = $window.FindName("ButtonInactiveComputers")
$ButtonDomainAdmins = $window.FindName("ButtonDomainAdmins")

############## FUNCIONS ##############
$data = Get-date -Format ddMMyy

Function ADComputers { 
    Add-Content -Path .\Export_AD_Computers_SS_$data.csv -Value ("CN" + ";" + "Enabled" + ";" + "dnshostname" + ";" + "OperatingSystem" + ";" + "OperatingSystemVersion" + ";" + "LastLogonTimeStamp" + ";" + "adminDescription" + ";" + "extensionAttribute1")
    $CercaADComputers = Get-ADComputer -filter * -Properties * 
    Foreach ($resultat in $CercaADComputers){
        $adminDescription = Get-ADComputer $resultat.cn -Properties adminDescription
        $extensionAttribute1 = Get-ADComputer $resultat.cn -Properties extensionAttribute1
        Add-Content -Path .\Export_AD_Computers_SS_$data.csv -Value ($resultat.cn + ";" + $resultat.Enabled + ";" + $resultat.dnshostname + ";" + $resultat.OperatingSystem + ";" + $resultat.OperatingSystemVersion + ";" + $resultat.lastlogontimestamp + ";" + $adminDescription.adminDescription + ";" + $extensionAttribute1.extensionAttribute1)
    }
    [System.Windows.MessageBox]::Show("Exportación finalizada", "Información", "Ok", "Information")
}
Function ADUsers {
    Add-Content -Path .\Export_AD_Users_SS_$data.csv -Value ("CN" + ";" + "DistinguishedName" + ";" + "Enabled" + ";" + "Name" + ";" + "samAccountName"+ ";" + "UserPrincipalName"+ ";" + "LastLogonTimeStamp")
    $CercaADUsers = Get-ADUser -Filter * -Properties *
    Foreach ($ResultatUser in $CercaADUsers){
        Add-Content -Path .\Export_AD_Users_SS_$data.csv -Value ($ResultatUser.cn + ";" + $ResultatUser.DistinguishedName + ";" + $ResultatUser.Enabled + ";" + $ResultatUser.Name + ";" + $ResultatUser.samAccountName + ";" + $ResultatUser.UserPrincipalName + ";" + $ResultatUser.lastlogontimestamp)
    }
    [System.Windows.MessageBox]::Show("Exportación finalizada", "Información", "Ok", "Information")
}

Function ADComputersIncorrect {
    $CercaCompIncorrect = Get-ADComputer -filter * -Properties * | Where-Object {($_.DistinguishedName -notlike "*OU=Workstations*") -AND ($_.DistinguishedName -notlike "*OU=Servers*") -AND ($_.DistinguishedName -notlike "*OU=Domain Controllers*") -AND ($_.DistinguishedName -notlike "*OU=Disabled Computers*")}
    Add-Content -Path .\Export_Comp_OU_Incorrecta_SS_$data.csv -Value ("Name" + ";" + "Enabled" + ";" + "LastLogonDate" + ";" + "DistinguishedName" + ";" + "OperatingSystem")
    Foreach ($ResultatCompOuInc in $CercaCompIncorrect){
        Add-Content -Path .\Export_Comp_OU_Incorrecta_SS_$data.csv -Value ($ResultatCompOuInc.Name + ";" + $ResultatCompOuInc.Enabled + ";" + $ResultatCompOuInc.LastLogonDate + ";" + $ResultatCompOuInc.DistinguishedName + ";" + $ResultatCompOuInc.operatingSystem)
    }
    [System.Windows.MessageBox]::Show("Exportación finalizada. No se han revisado equipos en las OUS: Workstations, Servers, Domain Controllers y Disabled Computers", "Información", "Ok", "Information")
}
Function ADUsersIncorrect {
    $CercaUsrIncorrect = Get-ADUser -filter * -Properties * | Where-Object {($_.DistinguishedName -notlike "*OU=T-Systems*") -AND ($_.DistinguishedName -notlike "*OU=Users*") -AND ($_.DistinguishedName -notlike "*OU=Shops*") -AND ($_.DistinguishedName -notlike "*OU=OFFICE 365 Diseable Accounts*") -AND ($_.DistinguishedName -notlike "*OU=Generic Accounts*") -AND ($_.DistinguishedName -notlike "*OU=OUT OF THE COMPANY*")} 
    Add-Content -Path .\Export_Users_OU_Incorrecta_SS_$data.csv -Value ("Name" + ";" + "Enabled" + ";" + "LastLogonDate" + ";" + "DistinguishedName" + ";" + "OperatingSystem")
    Foreach ($ResultatUsrIncorrect in $CercaUsrIncorrect){
        Add-Content -Path .\Export_Users_OU_Incorrecta_SS_$data.csv -Value ($ResultatUsrIncorrect.Name + ";" + $ResultatUsrIncorrect.Enabled + ";" + $ResultatUsrIncorrect.LastLogonDate + ";" + $ResultatUsrIncorrect.DistinguishedName)
    }
    [System.Windows.MessageBox]::Show("Exportación finalizada. No se han revisado usuarios en las OUS: T-Systems, Users, Shops, OFFICE 365 Diseable Accounts, Generic Accounts y OUT OF THE COMPANY", "Información", "Ok", "Information")
}
Function InactiveComputers {
    $Data180D = (Get-Date).AddDays(-90)
    $CercaCompInactive = Get-ADComputer -Filter {LastLogonTimestamp -lt $Data180D} -Properties * | Where-Object {($_.DistinguishedName -notlike "*OU=Domain Controllers*") -and ($_.DistinguishedName -notlike "*OU=Disabled Computers*") -and ($_.DistinguishedName -notlike "*OU=Servers*") -and ($_.DistinguishedName -notlike "*OU=OFFICE 365 Diseable Accounts*") -and ($_.DistinguishedName -notlike "*OU=OUT OF THE COMPANY*")} 
    Add-Content -Path .\Inactive_Computers_90D_SS_$data.csv -Value ("Name" + ";" + "CanonicalName" + ";" + "LastLogonTimestamp" + ";" + "LastLogonDate" + ";" + "Enabled" + ";" + "DistinguishedName")
    Foreach ($ResultatCompInactive in $CercaCompInactive){
        Add-Content -Path .\Inactive_Computers_90D_SS_$data.csv -Value ($ResultatCompInactive.Name + ";" + $ResultatCompInactive.CanonicalName + ";" + $ResultatCompInactive.LastLogonTimestamp + ";" + $ResultatCompInactive.LastLogonDate + ";" + $ResultatCompInactive.Enabled + ";" + $ResultatCompInactive.DistinguishedName)
    }
    [System.Windows.MessageBox]::Show("Exportación finalizada. No se han revisado equipos en las OUS: Domain Controllers, Disabled Computers, Servers, OFFICE 365 Diseable Accounts y OUT OF THE COMPANY", "Información", "Ok", "Information")
}
Function DomainAdmins { 
    $CercaDomainAdmins = Get-ADGroupMember -Identity 'Domain Admins' -Recursive
    Add-Content -Path .\Domain_Admins_SS_$data.csv -Value ("Name" + ";" + "SamAccountName")
    Foreach ($ResultatDomainAdmins in $CercaDomainAdmins){
        Add-Content -Path .\Domain_Admins_SS_$data.csv -Value ($ResultatDomainAdmins.Name + ";" + $ResultatDomainAdmins.SamAccountName)
    }
    [System.Windows.MessageBox]::Show("Exportación finalizada", "Información", "Ok", "Information")
}

############## ACCIONS BOTONS ##############
$ButtonADComputers.add_Click({ADComputers})
$ButtonADUsers.add_Click({ADUsers})
$ButtonADComputersIncorrect.add_Click({ADComputersIncorrect})
$ButtonADUsersIncorrect.add_Click({ADUsersIncorrect})
$ButtonInactiveComputers.add_Click({InactiveComputers})
$ButtonDomainAdmins.add_Click({DomainAdmins})

############## MOSTRA FORMULARI ##############
$Window.ShowDialog() | Out-Null