$objectesMoure = ("DSTERNER-LAPTOP",
"DWHITE-5410",
"DYLANF-5270",
"STEPHANIEZ-5410"
)

Foreach ($PC in $objectesMoure){
    $Equip = (Get-ADComputer $PC).DistinguishedName
    Move-ADObject $Equip -TargetPath "OU=021 Computer pending classify,DC=cosentinogroup,DC=net"
    Write-Host $Equip
}