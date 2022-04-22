$date = (Get-Date).AddYears(-1)
$info = Get-ADUser -Filter {LastLogonTimestamp -lt $date} -Properties * | Select-Object LastLogonDate, Name, Enabled, DistinguishedName | Export-Csv -Path "c:\users\enric.ferrer\desktop\1.csv" -Delimiter ";" -Encoding UTF8
