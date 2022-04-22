$WShell = New-Object -ComObject WScript.Shell

while (1) {
  #SHIFT+F15
  $WShell.SendKeys('+{F15}')
  Start-Sleep -seconds 10
}