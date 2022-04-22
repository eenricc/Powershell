Add-Type -AssemblyName System.Windows.Forms
$plusOrMinus = 200 

while ($true){
    $p = [System.Windows.Forms.Cursor]::Position
    $x = $p.X + $plusOrMinus
    $y = $p.Y + $plusOrMinus
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    $plusOrMinus *= -1
    Start-Sleep -Seconds 2
}