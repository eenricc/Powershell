## FUNCIONES
Function ContacteWSUS($Computer){
        Invoke-Command -computername $Computer -scriptblock {start-Service wuauserv}
        Invoke-Command -computername $Computer -scriptblock {$updateSession = new-object -com "Microsoft.Update.Session";$updates=$updateSession.CreateupdateSearcher().Search($criteria).Updates}
        Invoke-Command -computername $Computer -scriptblock {wuauclt /reportnow}
        Invoke-Command -computername $Computer -scriptblock {wuauclt /detectnow}
        Write-Host "Forzada replica a $Computer" -ForegroundColor Green    
}

## SCRIPT
$ErrorActionPreference = "SilentlyContinue"
#Ubicacion TXT de los equipos
$Equipos = Get-Content "C:\Users\enric.ferrer\Desktop\WSUS_Contacto.txt"
Foreach ($Equip in $Equipos){

    If (Test-WSMan -ComputerName $Equip) {
        ContacteWSUS($Equip)
    } Else {
        Write-host "Powershell remot deshabilitat a $Equip" -ForegroundColor Red
    }
}
