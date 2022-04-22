## TPM ##
$hostname = hostname
$tpmEnabled = Get-WmiObject -Namespace root/cimv2/security/microsofttpm -Class Win32_TPM | select-object IsEnabled_InitialValue
$tpmresult = $tpmEnabled.IsEnabled_InitialValue

## UNITATS ##
$units = (Get-Volume | Where-Object -Property drivetype -eq Fixed | Where-Object -Property DriveLetter -ne $null).DriveLetter

## ARXIU
Add-Content -Path "C:\users\enric.ferrer\desktop\$hostname - $tpmresult - $units.txt" -Value ("")  
#Add-Content -Path "C:\temp\$hostname - $tpmresult.txt" -Value ("")
#Copy-item "C:\temp\$hostname - $tpmresult.txt" -destination "\\cosentinogroup.net\DFS\DFS_COS\TPMDatos\"
