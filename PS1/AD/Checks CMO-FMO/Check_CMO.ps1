#DADES
$Servidor = Read-Host "Introdueix servidor"

#PING
if ( Test-Connection -ComputerName $Servidor -Count 1 -ErrorAction SilentlyContinue ) {
    Write-Host "PING"$Servidor": OK" -ForegroundColor Green 

    #HORA SERVIDOR
    $datahora = gwmi win32_operatingsystem -computer $Servidor
    $DHString = $datahora.converttodatetime($datahora.localdatetime)
    Write-Host "HORA"$Servidor":" $DHString -ForegroundColor Green

    #COMPARACIÓ AMB JUSCCM00
    $DH001 = gwmi win32_operatingsystem -computer JUSCCM00
    $DHRef = $DH001.converttodatetime($DH001.localdatetime)
    Write-Host "HORA JUSCCM00 :" $DHRef -ForegroundColor Yellow
    
    #ULTIM REINICI
    $LastBootUpTime = Get-WmiObject Win32_OperatingSystem -Comp $Servidor | Select -Exp LastBootUpTime
    $LastBoot = [System.Management.ManagementDateTimeConverter]::ToDateTime($LastBootUpTime)
    Write-Host "LAST BOOT UPTIME:" $LastBoot -ForegroundColor Blue

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
        Write-Host "DC DIAG $Servidor GLOBAL: OK" -ForegroundColor Green
    }
    
    
    #MOSTRA ELS ULTIMS 10 ERRORS AL EVENTVWR
    Write-Host "`n10 ULTIMS ERRORS:"
    $CapturaErrors = Get-EventLog -logname System -EntryType Error -Computername JUBRAUD04 -newest 10
    ForEach ($EventError in $CapturaErrors){
        write-host $EventError.Timegenerated "-" $EventError.Source -Foregroundcolor red
    }

    #MOSTRA ELS 10 ULTIMS RESULTATS AL EVENTVWR
    Write-Host "`n10 ULTIMS EVENTS:"
    $CapturaEvent = Get-EventLog -logname System -Computername JUBRAUD04 -newest 10
        ForEach ($Event in $CapturaEvent){
            If ($Event.Entrytype -eq "error"){ Write-Host $Event.Timegenerated "ERROR:" $Event.Source -Foregroundcolor red }
            If ($Event.Entrytype -eq "warning"){ Write-Host $Event.Timegenerated "WARNING:" $Event.Source -Foregroundcolor yellow }
            If ($Event.Entrytype -eq "information"){ Write-Host $Event.Timegenerated "INFO:" $Event.Source -Foregroundcolor green }
            If ($Event.Entrytype -eq "critical"){ Write-Host $Event.Timegenerated "CRITICAL:" $Event.Source -Foregroundcolor red }
        }
}
Else
{
    Write-Host "PING"$Servidor": KO" -ForegroundColor Red
}

Write-Host ""
Read-Host "Enter per sortir"