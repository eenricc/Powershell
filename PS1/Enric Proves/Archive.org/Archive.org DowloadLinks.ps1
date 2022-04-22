Add-Type -AssemblyName System.Web

#RUTA ON ESTA ARXIU TXT AMB ELS LINKS
$desktop = [Environment]::GetFolderPath("Desktop")
$links = get-content $Desktop\archiveorglinks.txt

ForEach ($link in $links){
    #Decodifiquem format URL-Encoded
    $decodedURL = [System.Web.HttpUtility]::UrlDecode($link)
    $nameGame = $decodedURL.split("/")[5]
    Write-Host $nameGame
    #DESCOMENTAR AQUESTA LINIA PER DESCARREGAR ARXIUS
    #Invoke-WebRequest -uri $link -OutFile $desktop\$nameGame
}

