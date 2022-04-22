#FUNCIÓ PER ESTABLIR BUILD DE WIN10
function ConvertTo-OperatingSystem {
    [CmdletBinding()]
    param(
        [string] $OperatingSystem,
        [string] $OperatingSystemVersion
    )
    if ($OperatingSystem -like 'Windows 10*') {
        $Systems = @{
            '10.0 (19043)' = "Windows 10 21H1"
            '10.0 (19042)' = "Windows 10 20H2"
            '10.0 (19041)' = "Windows 10 2004"
            '10.0 (18363)' = "Windows 10 1909"
            '10.0 (18362)' = "Windows 10 1903"
            '10.0 (17763)' = "Windows 10 1809"
            '10.0 (17134)' = "Windows 10 1803"
            '10.0 (16299)' = "Windows 10 1709"
            '10.0 (15063)' = "Windows 10 1703"
            '10.0 (14393)' = "Windows 10 1607"
            '10.0 (10586)' = "Windows 10 1511"
            '10.0 (10240)' = "Windows 10 1507"
            '10.0 (18898)' = 'Windows 10 Insider Preview'
        }
        $System = $Systems[$OperatingSystemVersion]
      #SI L'EQUIP NO ES WIN10 MOSTRA OS INDICAT PER AD
    } elseif ($OperatingSystem -notlike 'Windows 10*') {
        $System = $OperatingSystem
    }
    #EN CAS QUE NO HI HAGI INFORMACIÓ DE OS AL AD MOSTRA UNKNOWN
    if ($System) { $System } else { 'Unknown' }
}

#SCRIPT
$counter = 0
#PODEM AFEGIR PROPIETATS A EXTREURE DEL GET-ADCOMPUTER (NO CERCA A "COMPUTERS DISABLED")
$Computers = Get-ADComputer -Filter * -properties Name, DnsHostName, OperatingSystem, OperatingSystemVersion, LastLogonDate, whenCreated, Enabled, DistinguishedName | Where-Object {($_.DistinguishedName -notlike "*OU=-101 COMPUTERS DISABLED*")} 
$ComputerList = foreach ($computer in $Computers) {
    $counter = $counter + 1
    #ESTABLIM QUE SI NO HI HA IP AL DNS MOSTRI UNKNOWN (BUSCA IP AL DNS NO AL AD)
    Try { $IP = ([System.Net.Dns]::GetHostAddresses($computer.DNSHostName)).IPAddressToString }
    Catch {$IP = "Unknown"}
    [PSCustomObject] @{
        NAME                    = $computer.Name
        DNSHostName             = $computer.DnsHostName
        OperatingSystem         = $computer.OperatingSystem
        OperatingSystemVersion  = $computer.OperatingSystemVersion
        SYSTEM                  = ConvertTo-OperatingSystem -OperatingSystem $computer.OperatingSystem -OperatingSystemVersion $computer.OperatingSystemVersion
        IP                      = $IP
        LastLogonDate           = $computer.LastLogonDate
        WhenCreated             = $computer.WhenCreated  
        Enabled                 = $computer.Enabled 
        OU                      = $computer.DistinguishedName
    }
    
    
    
}
#RECOMPTE DE VERSIONS DE SO
$ComputerList | Group-Object -Property System | Sort-Object -Property Count -Descending | Format-Table -Property Name, Count #| Out-File -Append C:\Users\enric.ferrer\Desktop\1.csv -Encoding UTF8
Write-host "Total Computer Objects in AD:" $counter

#DETALL VERSIONS SO 
$ComputerList | Sort-Object -Property System -Descending | Format-Table | Out-File -Append C:\Users\enric.ferrer\Desktop\2.csv -Encoding UTF8
