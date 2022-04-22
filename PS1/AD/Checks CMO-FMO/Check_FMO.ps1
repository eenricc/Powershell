#DADES
$Servidor = Read-Host "Introdueix servidor"

#PING
if ( Test-Connection -ComputerName $Servidor -Count 1 -ErrorAction SilentlyContinue ) {
    Write-Host "`nPING"$Servidor": OK" -ForegroundColor Green 

    #HORA SERVIDOR
    $datahora = gwmi win32_operatingsystem -computer $Servidor
    $DHString = $datahora.converttodatetime($datahora.localdatetime)
    Write-Host "HORA"$Servidor":" $DHString -ForegroundColor Green

    #COMPARACIÓ AMB SRV2C01P001
    $DH001 = gwmi win32_operatingsystem -computer SRV2C01P001
    $DHRef = $DH001.converttodatetime($DH001.localdatetime)
    Write-Host "HORA SRV2C01P001:" $DHRef -ForegroundColor Yellow
    
    #ULTIM REINICI
    $LastBootUpTime = Get-WmiObject Win32_OperatingSystem -Comp $Servidor | Select -Exp LastBootUpTime
    $LastBoot = [System.Management.ManagementDateTimeConverter]::ToDateTime($LastBootUpTime)
    Write-Host "LAST BOOT UPTIME:" $LastBoot -ForegroundColor Gray

    #DCDIAG GLOBAL
    if ( dcdiag /test:Connectivity /test:Replications /test:NCSecDesc /test:NetLogons /test:KnowsOfRoleHolders /test:FSMOCheck /test:RidManager /test:ObjectsReplicated /test:VerifyReplicas /s:$Servidor /q ) {
        Write-Host "DC DIAG $Servidor GLOBAL KO:" -ForegroundColor Red
        #DCDIAG PER PARTS
        if ( dcdiag /test:Connectivity /s:$Servidor /q ) { Write-Host "-- KO DC $Servidor DIAG CONNECTIVITY" -ForegroundColor Red } else { Write-Host "-- OK DC DIAG $Servidor CONNECTIVITY" -ForegroundColor Green }
        if ( dcdiag /test:Replications /s:$Servidor /q ) { Write-Host "-- KO DC $Servidor DIAG REPLICATIONS" -ForegroundColor Red } else { Write-Host "-- OK DC DIAG $Servidor REPLICATIONS" -ForegroundColor Green }
        if ( dcdiag /test:NCSecDesc  /s:$Servidor /q ) { Write-Host "-- KO DC DIAG $Servidor NCSECDESC" -ForegroundColor Red } else { Write-Host "-- OK DC DIAG $Servidor NCSECDESC" -ForegroundColor Green }
        if ( dcdiag /test:NetLogons  /s:$Servidor /q ) { Write-Host "-- KO DC DIAG $Servidor NETLOGONS" -ForegroundColor Red } else { Write-Host "-- OK DC DIAG $Servidor NETLOGONS" -ForegroundColor Green }
        if ( dcdiag /test:KnowsOfRoleHolders  /s:$Servidor /q ) { Write-Host "-- KO DC DIAG $Servidor KNOWSOFROLEHOLDERS" -ForegroundColor Red } else { Write-Host "-- OK DC DIAG $Servidor KNOWSOFROLEHOLDERS" -ForegroundColor Green }
        if ( dcdiag /test:FSMOCheck  /s:$Servidor /q ) { Write-Host "-- KO DC DIAG $Servidor FSMOCHECK" -ForegroundColor Red } else { Write-Host "-- OK DC DIAG $Servidor FSMOCHECK" -ForegroundColor Green }
        if ( dcdiag /test:RidManager  /s:$Servidor /q ) { Write-Host "-- KO DC DIAG $Servidor RIDMANAGER" -ForegroundColor Red } else { Write-Host "-- OK DC DIAG $Servidor RIDMANAGER" -ForegroundColor Green }
        if ( dcdiag /test:ObjectsReplicated  /s:$Servidor /q ) { Write-Host "-- KO DC DIAG $Servidor OBJECTSREPLICATED" -ForegroundColor Red } else { Write-Host "-- OK DC DIAG $Servidor OBJECTSREPLICATED" -ForegroundColor Green }
        if ( dcdiag /test:VerifyReplicas  /s:$Servidor /q ) { Write-Host "-- KO DC DIAG $Servidor VERIFYREPLICAS" -ForegroundColor Red } else { Write-Host "-- OK DC DIAG $Servidor VERIFYREPLICAS" -ForegroundColor Green }
    }
    else
    {
        Write-Host "DC DIAG"$Servidor": OK" -ForegroundColor Green
    }

    #CHECK LT2C_ADDS
    $ADDS = Get-EventLog -newest 10 -logname System -Source "LT2C_ADDS" -ComputerName $Servidor
    Write-Host "`n Últimes 10 entrades LT2C_ADDS a $Servidor :`n"
    foreach($Hora in $adds){
        if ($hora.EntryType -eq "error") { Write-Host "LT2C_ADDS:" $hora.TimeGenerated " - KO" -ForegroundColor red }
        if ($hora.EntryType -eq "warning") { Write-Host "LT2C_ADDS:" $hora.TimeGenerated " - WARNING" -ForegroundColor yellow }
        if ($hora.EntryType -eq "information") { Write-Host "LT2C_ADDS:" $hora.TimeGenerated " - OK" -ForegroundColor green }
        if ($hora.EntryType -eq "critical") { Write-Host "LT2C_ADDS:" $hora.TimeGenerated " - CRITICAL" -ForegroundColor red }
    }
        
    #CHECK LT2C_PRINT
    $IsPrintServer = Get-WindowsFeature -name Print-Server -ComputerName $Servidor
    If ($IsPrintServer.InstallState -eq "Installed"){
        $PRINT = Get-EventLog -newest 10 -logname System -Source "LT2C_PRINT" -ComputerName $Servidor
        Write-Host "`n Últimes 10 entrades LT2C_PRINT a $Servidor :`n"
        foreach($Hora1 in $PRINT){
            if ($Hora1.EntryType -eq "error") { Write-Host "LT2C_PRINT:" $hora1.TimeGenerated " - KO" -ForegroundColor red }
            if ($Hora1.EntryType -eq "warning") { Write-Host "LT2C_PRINT:" $hora1.TimeGenerated " - WARNING" -ForegroundColor yellow }
            if ($Hora1.EntryType -eq "information") { Write-Host "LT2C_PRINT:" $hora1.TimeGenerated " - OK" -ForegroundColor green }
            if ($Hora1.EntryType -eq "critical") { Write-Host "LT2C_PRINT:" $hora1.TimeGenerated " - CRITICAL" -ForegroundColor red }
        }
    }
    Else
    {
    Write-Host "`nEl Servidor $Server no es PrintServer" -ForegroundColor YELLOW
    }

    #ULTIMS 5 ERRORS AL EVENTVWR
    Write-Host "`n Últims 5 errors al Eventvwr de $Servidor :`n"
    $CapturaErrors = Get-EventLog -LogName System -EntryType Error -ComputerName $Servidor -Newest 5
    ForEach ($EventError in $CapturaErrors){
        Write-Host $EventError.TimeGenerated "-" $EventError.Source -ForegroundColor Red
    }
}
Else
{
    Write-Host "`nPING"$Servidor": KO" -ForegroundColor Red
}

Read-Host "`n Intro per Sortir"