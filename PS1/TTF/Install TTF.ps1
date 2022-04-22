
Function EscriuLog ($LOGInfo) {    
    Add-content -Path $LogFile -Value $LOGInfo
}

#RUTA LOG
$Logfile = "C:\Windows\font_install.log"

#RUTA ON ESTAN LES FONTS
$SourceFolder = "\\Cosentinogroup.net\NETLOGON\Ruta_Fonts"

Add-Type -AssemblyName System.Drawing
$WindowsFonts = [System.Drawing.Text.PrivateFontCollection]::new()

Get-ChildItem -Path $SourceFolder -Include *.ttf, *.otf -Recurse -File | Copy-Item -Destination "$env:SystemRoot\Fonts" -Force -Confirm:$false -PassThru | ForEach-Object {
    EscriuLog "Installing font file $_.name"
    $WindowsFonts.AddFontFile($_.fullname)
    $RegistryValue = @{
        Path = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
        Name = $WindowsFonts.Families[-1].Name
        Value = $_.Fullname
    }

    $RemoveRegistry = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    Remove-ItemProperty -name $($WindowsFonts.Families[-1].Name) -path $RemoveRegistry
    New-ItemProperty @RegistryValue
}