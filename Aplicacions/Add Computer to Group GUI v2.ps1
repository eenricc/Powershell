## FORMULARI
Add-Type -AssemblyName PresentationFramework

############## GUI ##############

[XML]$XAMLCode = @"
<Window  
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:local="clr-namespace:Add_Computers_to_Group"
        Title="Add Group v1" Height="399.748" Width="236.368" ResizeMode="NoResize">
    <Grid Margin="0,0,2,10">
        <Grid.ColumnDefinitions>
            <ColumnDefinition/>
        </Grid.ColumnDefinitions>
        <Label Name="LabelGrup" Content="Grup:" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="10,10,0,0"/>
        <ListBox Name="ListBoxGrups" HorizontalAlignment="Left" Height="49" VerticalAlignment="Top" Width="210" Margin="10,36,0,0">
            <ListBoxItem Name="ListDefender" Content="TS - Windows Defender"/>
            <ListBoxItem Name="ListUmbrella" Content="TS - Umbrella Agent"/>
            <ListBoxItem Name="TestGrup" Content="TS - Test Grup"/>
        </ListBox>
        <Label Name="LabelLlista" Content="Equips / Usuaris:" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="11,90,0,0"/>
        <TextBox Name="TextBoxLlista" HorizontalAlignment="Left" Height="187" TextWrapping="Wrap" VerticalAlignment="Top" Width="209" Margin="11,121,0,0" VerticalScrollBarVisibility="Auto" AcceptsReturn="True"/>
        <Button Name="ButtonAfegeix" Content="Afegeix" HorizontalAlignment="Left" VerticalAlignment="Top" Width="209" Margin="11,331,0,0"/>

    </Grid>
</Window>
"@

## CARREGUEM FORMULARI
$Reader = (New-Object System.Xml.XmlNodeReader $XAMLCode)
$Window = [Windows.Markup.XamlReader]::Load($Reader)

#OBJECTES DEL FORMULARI
$XAMLCode.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name)}

############## VARIABLES ##############
$data = get-date -Format ddMMyy
$LogFile = ".\Add_Group_$data.csv"

############## FUNCIONS ##############
Function EscriuLog ($LOGInfo) {    
    Add-content -Path $LogFile -Value $LOGInfo
}

Function AfegeixGrups { 
    #Si afegim grups, cal afegir-los al SWITCH
    EscriuLog "Equipo;Grupo;Estado"
    $Seleccio = $ListBoxGrups.SelectedItem.Name
    
    Switch ($Seleccio){
        "ListDefender" { $Grup = "TS - Windows Defender"}
        "ListUmbrella" { $Grup = "TS - Windows Defender"}
        "TestGrup" { $Grup = "TS - Windows Defender"}
    }

    ForEach ($Equip in $TextBoxLlista.Text.Split("`n") | % {$_.trim()} ){
        Try {
            $SamAccount = Get-ADComputer -Identity $Equip
            ADD-ADGroupMember $Grup -Members $SamAccount.SamAccountName
            EscriuLog "$equip;$Grup;OK"
        } Catch {
            EscriuLog "$equip;$Grup;Error"
        }
    }
    [System.Windows.MessageBox]::Show("Finalitzat. Revisa el LOG generat", "Informacio", "Ok", "Information")
    $TextBoxLlista.Clear()
}

Function Check {
    If ($listBoxGrups.SelectedItem -eq $null){
        [System.Windows.MessageBox]::Show("Cal seleccionar un grup", "Alerta", "Ok", "Error")
    } ElseIf ($TextBoxLlista.Text -eq ""){ 
        [System.Windows.MessageBox]::Show("Cal omplir les dades d'equip", "Alerta", "Ok", "Error")
    } Else {
        AfegeixGrups
    }
}

############## ACCIONS BOTONS ##############
$ButtonAfegeix.add_Click({Check})


############## MOSTRA FORMULARI ##############
$Window.ShowDialog() | Out-Null