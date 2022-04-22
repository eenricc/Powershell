#* Informació: Del Visual Studio Community, cal esborrar el x:Class="MainWindow" i mc:Ignorable="d"
## FORMULARI
Add-Type -AssemblyName PresentationFramework

############## GUI ##############

[XML]$XAMLCode = @"

<Window x:Name="Test" 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"     
        Title="Prova!!" Height="450" Width="800">
    <Grid>
        <Button x:Name="Button" Content="Button" HorizontalAlignment="Left" VerticalAlignment="Top" Width="478" Margin="90,53,0,0" Height="265"/>

    </Grid>
</Window>
"@

## CARREGUEM FORMULARI
$Reader = (New-Object System.Xml.XmlNodeReader $XAMLCode)
$Window = [Windows.Markup.XamlReader]::Load($Reader)

#OBJECTES DEL FORMULARI
$Button = $window.FindName("Button")

############## FUNCIONS ##############
Function Parla{
    [System.Windows.MessageBox]::Show("Prova de botó", "Titol", "Ok", "Information")
}

############## ACCIONS BOTONS ##############
$Button.add_Click({Parla})


############## MOSTRA FORMULARI ##############
$Window.ShowDialog() | Out-Null