#ALERTA PER VEU
Add-Type -AssemblyName System.Speech
$Speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$text = "DISPONIBILIDAD"

#DADES DE LA URL
$url = "https://www.pixelheart.eu/produit/super-mario-world-2-yoshis-island-snes-pal/"
$response = Invoke-WebRequest -Uri $url
#Busquem el parametre CLASS a la web d'on posa que no hi ha estoc, en aquest cas soldout1
$Resultat = $response.ParsedHtml.body.getElementsByClassName('soldout1') | select -expand textContent

#A la web veiem que el text de soldout1 es OUT OF STOCK
while ($Resultat -eq "OUT OF STOCK"){
    write-host "OUT OF STOCK" -ForegroundColor Red
    #Cada quants segons fa check
    start-sleep 10
    $response = Invoke-WebRequest -Uri $url
    $Resultat = $response.ParsedHtml.body.getElementsByClassName('soldout1') | select -expand textContent
}

write-host "STOCK" -ForegroundColor green
$speak.speak($text)


    

    
