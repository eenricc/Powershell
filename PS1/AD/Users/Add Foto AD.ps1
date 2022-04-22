# FOTO EN FORMAT PNG
$Photo = [byte[]](Get-Content C:\users\enric.ferrer\desktop\pgidley.png -Encoding byte)
$User = "pgidley"
Set-ADUser $User -Replace @{thumbnailPhoto=$Photo}