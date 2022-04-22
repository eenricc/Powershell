$equips = @(
"RMSANCHEZ-T570",
"JMBENITO-T580"
)

Foreach ($equip in $equips){
    Try {
        $preband = Get-NetAdapterAdvancedProperty -Name *Wi* -cimsession $equip | where-object -FilterScript {$_.displayname -eq "Preferred Band"} -ErrorAction SilentlyContinue
        $banda = Get-NetAdapterAdvancedProperty -Name *Wi* -cimsession $equip | where-object -FilterScript {$_.displayname -eq "Banda preferida"} -ErrorAction SilentlyContinue
        If (($preband.RegistryValue -eq "2") -or ($banda.RegistryValue -eq "2")){
            Write-Host $equip "- Banda:"$preband.RegistryValue $banda.RegistryValue -ForegroundColor Green
        } Else {
            Write-Host $equip "- Banda:"$preband.RegistryValue $banda.RegistryValue -ForegroundColor Red
        }
        
    } Catch {
        Write-Host $equip "- Sense conexió Enter-PSSesion" -ForegroundColor Yellow
    }   
}


