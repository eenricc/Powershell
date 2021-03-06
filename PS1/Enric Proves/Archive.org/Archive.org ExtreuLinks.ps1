#WEB DE ARCHIVE.ORG AMB LINKS
$rooturl = "https://archive.org/download/nointro.gb/"

#RUTA EXTRACCIO TXT
$desktop = [Environment]::GetFolderPath("Desktop")
$savefile = "$desktop\archiveorglinks.txt"

#BUSQUEM LINKS I FILTREM PER REGIO o NO FILTREM
#$links = (Invoke-WebRequest -Uri $rooturl).Links | Where-Object {($_.innerHTML -ne "View Contents") -and (($_.href -like "*USA*") -or ($_.href -like "*World*")) -and ($_.href -like "*.7z")} | Select-Object -ExpandProperty href

#En alguns casos s'ha canviat el href per un altre format, depenent del link. 
$links = (Invoke-WebRequest -Uri $rooturl).Links | Where-Object {($_.innerHTML -ne "View Contents") -and ($_.href -like "*.zip")} | Select-Object -ExpandProperty href

$URLs = @()
foreach ($link in $links){
    $URLs += $rooturl + $link
}

$URLs | Out-File -FilePath $savefile