$directori = Get-ChildItem -Path "\\cositxdc01\Bmc_Client\TEST"
Add-Content -Path "C:\users\enric.ferrer\desktop\TPM_Read.csv" -Value ("Hostname" + ";" + "IsEnabled" + ";" + "Units")
foreach ($arxiu in $directori){
    $versionFinal = $arxiu.name -replace ".txt", "" -replace " - ",";"
    Add-Content -Path "C:\users\enric.ferrer\desktop\TPM_Read.csv" -Value ($versionFinal)
}