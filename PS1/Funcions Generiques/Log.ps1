#### BASICA
$CarpetaLOG = "C:\Users\A348397\OneDrive - Deutsche Telekom AG\Desktop\Sogeking\"
Add-Content -Path "$CarpetaLOG\Test.csv" -Value ("CN" + ";" + "Enfante")

#### AMB FUNCIO
$LogFile = "C:\Users\A348397\OneDrive - Deutsche Telekom AG\Desktop\Sogeking\Test.csv"

Function EscriuLog ($LOGInfo) {    
    Add-content -Path $LogFile -Value $LOGInfo
}

#Envio la info a la funcio
EscriuLog "$equip;$Grup;Error"
#Si son parametres de variable, s'envia aixi
EscriuLog ($user.cn + ";" + $user.SamAccountName + ";Error Data")