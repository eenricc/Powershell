#SCRIPT
$counter = 0
$Servers = Get-ADComputer -Filter 'operatingsystem -like "*server*"' -properties Name, OperatingSystem, OperatingSystemVersion, Enabled
$ServerList = foreach ($Server in $Servers) {
    $counter = $counter + 1
    #ESTABLIM QUE SI NO HI HA IP AL DNS MOSTRI UNKNOWN (BUSCA IP AL DNS NO AL AD)
    Try { $IP = ([System.Net.Dns]::GetHostAddresses($Server.DNSHostName)).IPAddressToString }
    Catch {$IP = "Unknown"}
    [PSCustomObject] @{
        NAME                    = $Server.Name
        OperatingSystem         = $Server.OperatingSystem
        OperatingSystemVersion  = $Server.OperatingSystemVersion
        IP                      = $IP
        Enabled                 = $Server.Enabled        
    }   
}
#RECOMPTE DE VERSIONS PER SO
$ServerList | Group-Object -Property OperatingSystem | Sort-Object -Property Count -Descending | Format-Table -Property Name, Count #| Out-File -Append C:\Users\enric.ferrer\Desktop\1.csv -Encoding UTF8
Write-host "Total Computer Objects in AD:" $counter

#DETALL VERSIONS SO (Per realitzar exportació a arxiu, treure el out-gridview)
$ServerList | Sort-Object -Property OperatingSystem -Descending | Out-GridView | Format-Table -AutoSize #| Out-File -Append C:\Users\enric.ferrer\Desktop\2.csv -Encoding UTF8
