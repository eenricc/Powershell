## Modificar primera linia --> <Window x:Class=”WpfApplication9.MainWindow” --> <Window
## Esborrar --> xmlns:local="clr-namespace:WpfApplication9"                        
## Esborrar --> mc:Ignorable="d"                                                   
## Modificar --> x:Name=  to Name=                                                 

## DEFINIM CLASS
Add-Type -AssemblyName PresentationFramework

## ENTORN VISUAL

[XML]$XAML = @"

<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="Dades PC" Height="227" Width="315" ResizeMode="NoResize">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="122*"/>
            <ColumnDefinition Width="193*"/>
        </Grid.ColumnDefinitions>
        <Label Name="labelHostname" Content="Hostname: " HorizontalAlignment="Left" Margin="43,44,0,0" VerticalAlignment="Top" Height="26" Width="70"/>
        <TextBox Name="textboxHost" Grid.Column="1" HorizontalAlignment="Left" Margin="10,48,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120"/>
        <Button Name="buttonHost" Content="Hostname" RenderTransformOrigin="0.5,0.5" Grid.ColumnSpan="2" Margin="79,106,98,72">
            <Button.RenderTransform>
                <TransformGroup>
                    <ScaleTransform/>
                    <SkewTransform/>
                    <RotateTransform Angle="0.72"/>
                    <TranslateTransform/>
                </TransformGroup>
            </Button.RenderTransform>
        </Button>

    </Grid>
</Window>

"@

## CARREGUEM FORMULARI
$Reader = (New-Object System.Xml.XmlNodeReader $XAML)
$Form = [Windows.Markup.XamlReader]::Load($Reader)

## OBJECTES DEL FORMULARI (Genera la variable amb el NAME que tinguin al XAML)
$XAML.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}

## FUNCIONS

Function hostname{
    $textboxHost.text = $env:COMPUTERNAME
}

## ACCIONS BOTONS 
$buttonHost.add_Click({Hostname})

## MOSTRA FORMULARI 
$Form.ShowDialog() | Out-Null