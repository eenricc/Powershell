#Conectar con local admin del tenant para gestión de 365
Function connect365_admin {
$User = "sistemas@grupocosentino.onmicrosoft.com"
$FileCredential = "C:\scripts\Credential.txt"
$Pword = Get-Content C:\scripts\Credential.txt | ConvertTo-SecureString
$Credential = New-Object System.Management.Automation.PSCredential($User, $PWord)
$UserCredential = $Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
}

#Conectar con usuario nominal al tenant para gestión de 365
Function connect365 {
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
}

#conectar con local admin del tenant para liberación de licencias
Function 365Licenses {
import-module MSOnline
$User = "sistemas@grupocosentino.onmicrosoft.com"
$FileCredential = "C:\scripts\Credential.txt"
$Pword = Get-Content $FileCredential | ConvertTo-SecureString
$Credential = New-Object System.Management.Automation.PSCredential($User, $PWord)
Connect-MsolService -Credential $Credential
}

Function 365Licenses_ {
import-module MSOnline
$User = "sincronizacion@grupocosentino.onmicrosoft.com"
$PWord = ConvertTo-SecureString –String "D4t0&C0s3nt1n01*" –AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($User, $PWord)
Connect-MsolService -Credential $Credential
}


Function connect365_admin_ {
$User = "sincronizacion@grupocosentino.onmicrosoft.com"
$PWord = ConvertTo-SecureString –String "D4t0&C0s3nt1n01*" –AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($User, $PWord)
$UserCredential = $Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
}