Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$CheckMail                       = New-Object system.Windows.Forms.Form
$CheckMail.ClientSize            = New-Object System.Drawing.Point(330,320)
$CheckMail.text                  = "Check INBOX"
$CheckMail.TopMost               = $false
$CheckMail.FormBorderStyle       = 'FixedDialog'
$CheckMail.StartPosition         = "CenterScreen"
$CheckMail.MinimizeBox           = $False
$CheckMail.MaximizeBox           = $False

$TextBoxEntrada                  = New-Object system.Windows.Forms.TextBox
$TextBoxEntrada.multiline        = $false
$TextBoxEntrada.TextAlign        = "Center"
$TextBoxEntrada.width            = 150
$TextBoxEntrada.height           = 20
$TextBoxEntrada.location         = New-Object System.Drawing.Point(10,59)
$TextBoxEntrada.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',100)
$TextBoxEntrada.ReadOnly         = $True

$TextBoxCosentino                = New-Object system.Windows.Forms.TextBox
$TextBoxCosentino.multiline      = $false
$TextBoxCosentino.TextAlign      = "Center"
$TextBoxCosentino.width          = 150
$TextBoxCosentino.height         = 20
$TextBoxCosentino.location       = New-Object System.Drawing.Point(172,60)
$TextBoxCosentino.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',100)
$TextBoxCosentino.ReadOnly         = $True

$LabelEntrada                    = New-Object system.Windows.Forms.Label
$LabelEntrada.text               = "Bústia d`'entrada"
$LabelEntrada.AutoSize           = $true
$LabelEntrada.width              = 25
$LabelEntrada.height             = 10
$LabelEntrada.location           = New-Object System.Drawing.Point(40,30)
$LabelEntrada.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$LabelCosentino                  = New-Object system.Windows.Forms.Label
$LabelCosentino.text             = "COS IT SUPPORT"
$LabelCosentino.AutoSize         = $true
$LabelCosentino.width            = 25
$LabelCosentino.height           = 10
$LabelCosentino.location         = New-Object System.Drawing.Point(190,30)
$LabelCosentino.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$TextBoxStartStop                = New-Object system.Windows.Forms.TextBox
$TextBoxStartStop.multiline      = $false
$TextBoxStartStop.TextAlign      = "Center"
$TextBoxStartStop.width          = 100
$TextBoxStartStop.height         = 10
$TextBoxStartStop.location       = New-Object System.Drawing.Point(115,230)
$TextBoxStartStop.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$TextBoxStartStop.ReadOnly       = $True
$TextBoxStartStop.Text           = "ATURAT"
$TextBoxStartStop.BackColor      = "RED"
$TextBoxStartStop.ForeColor      = "WHITE"

$ButtonStartStop                 = New-Object system.Windows.Forms.Button
$ButtonStartStop.text            = "START"
$ButtonStartStop.width           = 200
$ButtonStartStop.height          = 30
$ButtonStartStop.location        = New-Object System.Drawing.Point(10,270)
$ButtonStartStop.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$ButtonStartStop.add_click({Inicia})

$CancelButton                 = New-Object system.Windows.Forms.Button
$CancelButton.text            = "Atura"
$CancelButton.width           = 100
$CancelButton.height          = 30
$CancelButton.location        = New-Object System.Drawing.Point(220,270)
$CancelButton.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$CancelButton.add_click({Atura})


$CheckMail.controls.AddRange(@($TextBoxEntrada,$LabelEntrada,$LabelCosentino,$ButtonStartStop,$TextBoxCosentino,$CancelButton,$TextBoxStartStop))

#FUNCIONS

#BUCLE
function Atura{
$Script:CancelLoop               = $True
$TextBoxStartStop.text           = "ATURAT"
$TextBoxStartStop.BackColor      = "RED"
$ButtonStartStop.Enabled         = $True
}

function Inicia {

If (Get-Process -name OUTLOOK -ErrorAction SilentlyContinue){

    $Script:CancelLoop = $false
    $TextBoxStartStop.text           = "ACTIU"
    $TextBoxStartStop.BackColor      = "GREEN"
    $ButtonStartStop.Enabled         = $False



    While ($Script:CancelLoop -eq $false){
        [System.Windows.Forms.Application]::DoEvents()
        $outlook = New-Object -ComObject Outlook.Application
        $session = $outlook.Session
        $session.Logon()

        #BUSTIA D'ENTRADA
        $total = 0
        $inbox = $session.GetDefaultFolder(6)
        $mails = $inbox.items
        $Unread = $mails | where {$_.UnRead -eq "$True"} | Select-Object -Property ReceivedTime, Subject, SenderName

        #CARPETA COSENTINO
        $totalCOS = 0
        $CosentinoFolder = $inbox.Folders | where-object { $_.name -eq "COS IT SUPPORT" }
        $COS_Mails = $CosentinoFolder.items
        $UnreadCos = $COS_Mails | where {$_.UnRead -eq "$True"} | Select-Object -Property ReceivedTime, Subject, SenderName

        #RECOMPTE INBOX
        foreach ($new in $unread){
            $total = $total + 1
        }

        #RECOMPTE COSENTINO FOLDER
        foreach ($newCOS in $unreadCOS){
            $totalCOS = $totalCOS + 1
        }

        If ($Total -ne "0"){ $TextBoxEntrada.BackColor = "Red" } else {$TextBoxEntrada.BackColor = "White"}
        If ($TotalCOS -ne "0"){ $TextBoxCosentino.BackColor = "Red" } else {$TextBoxCosentino.BackColor = "White"}
        $TextBoxEntrada.Text = $Total  
        $TextBoxCosentino.Text = $totalCOS  
    
    }

}else{

    [System.Windows.MessageBox]::Show("Outlook no iniciat. Obre Outlook abans d'executar el comptador")
    }
}

$CheckMail.ShowDialog()

