$prvDate = ((Get-Date).AddDays(-15)).Date
Get-ADUser -Filter {whenCreated -ge $prvDate} -Properties whenCreated | Select Name, whenCreated, sAMAccountName | Sort-Object whenCreated