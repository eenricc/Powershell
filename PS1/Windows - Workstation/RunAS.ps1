$local = 10.200.145.98
$cred = New-Object System.Management.Automation.PsCredential("$local\dgu_admin.loc", (ConvertTo-SecureString "Abc_12345" -AsPlainText -Force))
$path = "D:\Prova\Disco.exe"
Start-Process $path -Credential $cred