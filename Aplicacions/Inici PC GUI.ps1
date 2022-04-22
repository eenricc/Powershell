Add-Type -AssemblyName System.Windows.Forms

#PER DESAR CLAUS AMB EL CANVI DE PASS
#cmdkey /generic:"160.118.43.6" /user:"WNJPSP112\eferrer" /pass:"Primera-150781"
#cmdkey /generic:"160.118.43.5" /user:"WNJPSP111\eferrer" /pass:"Primera-150781"

#ESBORRAR CLAUS AMB EL CANVI DE PASS
#cmdkey /delete:"160.118.43.6"
#cmdkey /delete:"160.118.43.5"

$Form = New-Object system.Windows.Forms.Form
$Form.Text = "Inici equip"
$Form.TopMost = $true
$Form.Width = 315
$Form.Height = 135
$form.FormBorderStyle = 'FixedDialog'
$form.StartPosition = "CenterScreen"
$Form.MinimizeBox = $False
$Form.MaximizeBox = $False
$Form.Icon = New-Object system.drawing.icon ("D:\Users\eferrer\Documents\Icons\play.ico")

$button2 = New-Object system.windows.Forms.Button
$button2.Text = "Outlook"
$button2.Width = 142
$button2.Height = 43
$button2.Add_Click({Outlook})
$button2.location = new-object system.drawing.point(6,7)
$button2.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($button2)

$Button = New-Object system.windows.Forms.Button
$Button.Text = "Chrome"
$Button.Width = 142
$Button.Height = 43
$Button.Add_Click({Chrome})
$Button.location = new-object system.drawing.point(153,7)
$Button.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($Button)

$button4 = New-Object system.windows.Forms.Button
$button4.Text = "Jump CMO"
$button4.Width = 142
$button4.Height = 43
$button4.Add_Click({JumpCMO})
$button4.location = new-object system.drawing.point(6,54)
$button4.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($button4)

$button5 = New-Object system.windows.Forms.Button
$button5.Text = "Jump FMO"
$button5.Width = 142
$button5.Height = 43
$button5.Add_Click({JumpFMO})
$button5.location = new-object system.drawing.point(153,54)
$button5.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($button5)

#FUNCIONS DELS BOTONS
function Outlook{Start-Process "C:\Program Files\Microsoft Office\Office15\outlook.exe"}
function JumpCMO{Start-Process "D:\Users\eferrer\Desktop\Scripts\INICI\WNJPSP112 - CMO.rdp"}
function JumpFMO{Start-Process "D:\Users\eferrer\Desktop\Scripts\INICI\WNJPSP111 - FMO.rdp"}
function Chrome{Start-Process "C:\Program Files\Google\Chrome\Application\Chrome.exe"}

[void]$Form.ShowDialog()
$Form.Dispose()