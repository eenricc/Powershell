﻿$Computer = "HOSTNAME"
Get-WMIObject Win32_NetworkAdapterConfiguration -Computername $Computer | Where-Object {$_.IPEnabled -match "True"} | Select-Object -property DNSHostName,@{N="DNS";E={"$($_.DNSServerSearchOrder)"}},@{N='IPAddress';E={$_.IPAddress}},@{N='DefaultIPGateway';E={$_.DefaultIPGateway}} | FT