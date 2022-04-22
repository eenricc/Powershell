########## VARIABLES ##########
$Arxiu = Get-Content "C:\Users\enric.ferrer\Desktop\1.txt" -ErrorAction SilentlyContinue
$Grup = "TS - BMC Agent Pol"

If ($Arxiu){
    ForEach ($Equip in $Arxiu){
        $Existeix = "Si"
        Try {$SamAccount = Get-ADComputer -Identity $Equip} Catch {$Existeix = "No"}
        If ($Existeix -eq "Si"){
            ADD-ADGroupMember $Grup -Members $SamAccount.SamAccountName
            Write-Host "$Equip - Afegit correctament" -ForegroundColor Green
        } Else {
            Write-Host "$Equip - No apareix a AD" -ForegroundColor Red
        }
    }
} Else {
    Write-Host "No existeix arxiu d'entrada"
}