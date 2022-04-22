$Iberia = "OU=01 IBERIA,OU=-001 COSENTINO USERS,DC=cosentinogroup,DC=net"
$Europe = "OU=02 EUROPE,OU=-001 COSENTINO USERS,DC=cosentinogroup,DC=net"
$NA = "OU=03 NORTH AMERICA,OU=-001 COSENTINO USERS,DC=cosentinogroup,DC=net"
$Latam = "OU=04 LATAM,OU=-001 COSENTINO USERS,DC=cosentinogroup,DC=net"
$Oceania = "OU=05 OCEANIA,OU=-001 COSENTINO USERS,DC=cosentinogroup,DC=net"
$Asia = "OU=06 ASIA,OU=-001 COSENTINO USERS,DC=cosentinogroup,DC=net"
$NewOnboarding = "OU=08 NEW ONBOARDING,OU=-001 COSENTINO USERS,DC=cosentinogroup,DC=net"

$IberiaTotal = (Get-ADUser -Filter * -SearchBase $Iberia).count
$IberiaEnabled = (Get-ADUser -Filter 'enabled -eq $true' -SearchBase $Iberia).count

$EuropeTotal = (Get-ADUser -Filter * -SearchBase $Europe).count
$EuropeEnabled = (Get-ADUser -Filter 'enabled -eq $true' -SearchBase $Europe).count

$NATotal = (Get-ADUser -Filter * -SearchBase $NA).count
$NAEnabled = (Get-ADUser -Filter 'enabled -eq $true' -SearchBase $NA).count

$LatamTotal = (Get-ADUser -Filter * -SearchBase $Latam).count
$LatamEnabled = (Get-ADUser -Filter 'enabled -eq $true' -SearchBase $Latam).count

$OceaniaTotal = (Get-ADUser -Filter * -SearchBase $Oceania).count
$OceaniaEnabled = (Get-ADUser -Filter 'enabled -eq $true' -SearchBase $Oceania).count

$AsiaTotal = (Get-ADUser -Filter * -SearchBase $Asia).count
$AsiaEnabled = (Get-ADUser -Filter 'enabled -eq $true' -SearchBase $Asia).count

$NewOnboardingTotal = (Get-ADUser -Filter * -SearchBase $NewOnboarding).count
$NewOnboardingEnabled = (Get-ADUser -Filter 'enabled -eq $true' -SearchBase $NewOnboarding).count

Write-Host "01 IBERIA TOTAL: $IberiaTotal // Enabled: $IberiaEnabled"
Write-Host "02 EUROPE: $EuropeTotal // Enabled: $EuropeEnabled"
Write-Host "03 NORTH AMERICA: $NATotal // Enabled: $NAEnabled"
Write-Host "04 LATAM: $LatamTotal // Enabled: $LatamEnabled"
Write-Host "05 OCEANIA: $OceaniaTotal // Enabled: $OceaniaEnabled"
Write-Host "06 ASIA: $AsiaTotal // Enabled: $AsiaEnabled"
Write-Host "08 NEW ONBOARDING: $NewOnboardingTotal // Enabled: $NewOnboardingEnabled"
