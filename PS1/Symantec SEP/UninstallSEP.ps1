$Computer = "HOSTNAME"

$desinstalacion = (Get-WmiObject -Class Win32_Product -Filter "Name='Symantec Endpoint Protection'" -ComputerName $computer).identifyingNumber
Invoke-Command -ComputerName $computer -ScriptBlock {msiexec /x $desinstalacion /qn /l*v c:\uninstallSEP.txt} 
