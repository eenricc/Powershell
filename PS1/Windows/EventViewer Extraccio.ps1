#4738 - modifiacci´ño usuari
#4624 Login OK
#-MaxEvents 10
Get-WinEvent –FilterHashtable @{logname='security';id=4738} | fl *