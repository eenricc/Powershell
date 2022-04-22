$Equips = @("DGU2C000859",
"DGU2C000860",
"DGU2C085731",
"DGU2C086760",
"DGU2C086830",
"DGU2C114434")


$SourceDomain = 'GCC'
$SiteCode = 'CAT'
$SCCMPSModule = 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'

Import-Module ActiveDirectory
Import-Module -Name $SCCMPSModule
Set-Location "$($SiteCode):"

Foreach ($equip in $Equips){
    Write-Host "$equip : " (Get-CMUserDeviceAffinity -DeviceName $equip).UniqueUserName
    #write-host "$equip : " (Get-ADUser -identity $equip -Properties *).displayname

    
}