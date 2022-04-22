#DECLARACIO FORMULARI + VARIABLES
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#BASE FORMULARI
$Form = New-Object system.Windows.Forms.Form
$form.Text = "Check FMO"
$form.Size = New-Object System.Drawing.Size (900, 600)
$form.FormBorderStyle = 'FixedDialog'
$form.StartPosition = "CenterScreen"
$Form.MinimizeBox = $False
$Form.MaximizeBox = $False
#$Form.WindowState = "Maximized" # Maximized, Minimized, Normal
#$form.Icon = New-Object system.drawing.icon ("D:\Ruta")

#TEXT
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Servidor:"
$Label.Location = New-Object System.Drawing.Size (10,32)
$Label.Size = New-Object System.Drawing.Size (50,20)
$Form.Controls.Add($Label)

$LabelPing = New-Object System.Windows.Forms.Label
$LabelPing.Text = "Ping:"
$LabelPing.Location = New-Object System.Drawing.Size (10,82)
$LabelPing.Size = New-Object System.Drawing.Size (50,20)
$Form.Controls.Add($LabelPing)

$LabelHora = New-Object System.Windows.Forms.Label
$LabelHora.Text = "Hora:"
$LabelHora.Location = New-Object System.Drawing.Size (10,122)
$LabelHora.Size = New-Object System.Drawing.Size (50,20)
$Form.Controls.Add($LabelHora)

$LabelReinici = New-Object System.Windows.Forms.Label
$LabelReinici.Text = "Últim Reinici:"
$LabelReinici.Location = New-Object System.Drawing.Size (10,155)
$LabelReinici.Size = New-Object System.Drawing.Size (50,30)
$Form.Controls.Add($LabelReinici)

$LabelDCDiag = New-Object System.Windows.Forms.Label
$LabelDCDiag.Text = "DCDiag:"
$LabelDCDiag.Location = New-Object System.Drawing.Size (10,202)
$LabelDCDiag.Size = New-Object System.Drawing.Size (50,20)
$Form.Controls.Add($LabelDCDiag)

#TEXTBOX
$TextBoxServer = New-Object System.Windows.Forms.TextBox
$textBoxServer.Location = New-Object System.Drawing.Size (65,30)
$textBoxServer.Size = New-Object System.Drawing.Size (120,50)
$textBoxServer.Multiline = $false
$textBoxServer.ScrollBars = 'None'
$form.Controls.Add($textBoxServer)

$TextBoxPing = New-Object System.Windows.Forms.TextBox
$textboxping.Location = New-Object System.Drawing.Size (65,80)
$textBoxping.Size = New-Object System.Drawing.Size (120,50)
$textBoxping.Multiline = $false
$textBoxping.ScrollBars = 'None'
$textBoxping.ReadOnly = $true
$TextBoxPing.TextAlign = 'Center'
$form.Controls.Add($textBoxPing)

$TextBoxHora = New-Object System.Windows.Forms.TextBox
$textboxHora.Location = New-Object System.Drawing.Size (65,120)
$textBoxHora.Size = New-Object System.Drawing.Size (120,50)
$textBoxHora.Multiline = $false
$textBoxHora.ScrollBars = 'None'
$textBoxHora.ReadOnly = $true
$TextBoxHora.TextAlign = 'Center'
$form.Controls.Add($textBoxHora)

$TextBoxReinici = New-Object System.Windows.Forms.TextBox
$textboxReinici.Location = New-Object System.Drawing.Size (65,160)
$textboxReinici.Size = New-Object System.Drawing.Size (120,50)
$textboxReinici.Multiline = $false
$textboxReinici.ScrollBars = 'None'
$textboxReinici.ReadOnly = $true
$TextBoxReinici.TextAlign = 'Center'
$form.Controls.Add($textboxReinici)

$TextBoxDCDiag = New-Object System.Windows.Forms.TextBox
$textboxDCDiag.Location = New-Object System.Drawing.Size (65,200)
$textboxDCDiag.Size = New-Object System.Drawing.Size (120,50)
$textboxDCDiag.Multiline = $false
$textboxDCDiag.ScrollBars = 'None'
$textboxDCDiag.ReadOnly = $true
$TextBoxDCDiag.TextAlign = 'Center'
$form.Controls.Add($textboxDCDiag)

$TextBoxInfo = New-Object System.Windows.Forms.TextBox
$textboxInfo.Location = New-Object System.Drawing.Size (200,30)
$textboxInfo.Size = New-Object System.Drawing.Size (650,500)
$textboxInfo.Multiline = $true;
$textboxInfo.ScrollBars = 'Both'
#$textboxInfo.ReadOnly = $true
$form.Controls.Add($textboxInfo)

#BOTONS
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Size (40,250)
$Button.Size = New-Object System.Drawing.Size(120,30)
$button.Text = "Check Servidor"
$button.add_click({Check($textboxserver.text)})
$Form.Controls.Add($button)

$buttonADDS = New-Object System.Windows.Forms.Button
$buttonADDS.Location = New-Object System.Drawing.Size (40,300)
$buttonADDS.Size = New-Object System.Drawing.Size(120,30)
$buttonADDS.Text = "LT2C ADDS"
$buttonADDS.add_click({ADDS($textboxserver.text)})
$Form.Controls.Add($buttonADDS)

$buttonPrint = New-Object System.Windows.Forms.Button
$buttonPrint.Location = New-Object System.Drawing.Size (40,350)
$buttonPrint.Size = New-Object System.Drawing.Size(120,30)
$buttonPrint.Text = "LT2C Print"
$buttonPrint.add_click({PRINT($textboxserver.text)})
$Form.Controls.Add($buttonPrint)

$buttonErrors = New-Object System.Windows.Forms.Button
$buttonErrors.Location = New-Object System.Drawing.Size (40,400)
$buttonErrors.Size = New-Object System.Drawing.Size(120,30)
$buttonErrors.Text = "Últims 5 Errors"
$buttonErrors.add_click({ERRORS($textboxserver.text)})
$Form.Controls.Add($buttonErrors)

$buttonClear = New-Object System.Windows.Forms.Button
$buttonClear.Location = New-Object System.Drawing.Size (40,450)
$buttonClear.Size = New-Object System.Drawing.Size(120,30)
$buttonClear.Text = "Neteja"
$ButtonClear.add_click{Neteja}
$Form.Controls.Add($buttonClear)

$buttonExit = New-Object System.Windows.Forms.Button
$buttonExit.Location = New-Object System.Drawing.Size (40,500)
$buttonExit.Size = New-Object System.Drawing.Size(120,30)
$buttonExit.Text = "Sortir"
$buttonExit.add_click{$Form.Close()}
$Form.Controls.Add($buttonExit)

#FUNCIONS DELS BOTONS
function Neteja{
$TextBoxServer.Clear()
$TextBoxInfo.Clear()
$TextBoxPing.Clear()
$TextBoxPing.BackColor = "White"
$TextBoxHora.Clear()
$TextBoxreinici.Clear()
$TextBoxDCDiag.Clear()
$TextBoxDCDiag.BackColor = "White"
}
function Check($Servidor){
If ($Servidor){
    if (Test-Connection -ComputerName $Servidor -Count 1 -ErrorAction SilentlyContinue ) {
            $textboxping.BackColor = "Green"
            $textboxping.Text = "OK"

            $datahora = gwmi win32_operatingsystem -computer $Servidor
            $DHString = $datahora.converttodatetime($datahora.localdatetime)
            $textboxhora.text = $DHString.ToString()

            $LastBootUpTime = Get-WmiObject Win32_OperatingSystem -Comp $Servidor | Select -Exp LastBootUpTime
            $LastBoot = [System.Management.ManagementDateTimeConverter]::ToDateTime($LastBootUpTime)
            $textboxReinici.Text = $lastboot.ToString()

            if ( dcdiag /test:Connectivity /test:Replications /test:NCSecDesc /test:NetLogons /test:KnowsOfRoleHolders /test:FSMOCheck /test:RidManager /test:ObjectsReplicated /test:VerifyReplicas /s:$Servidor /q ) {
                $textboxDCDiag.Backcolor = "Red"
                $textboxDCDiag.Text = "KO"
            }else{
                $textboxDCDiag.Backcolor = "Green"
                $textboxDCDiag.Text = "OK"
            }
         
    }else{
            $textboxping.BackColor = "Red"
            $textboxping.text = "KO"
    }
}else{
    $TextBoxInfo.Text = "Cal introduir servidor"
    }
}

function ADDS($Servidor){
If ($Servidor){
    $ADDS = Get-EventLog -newest 10 -logname System -Source "LT2C_ADDS" -ComputerName $Servidor
     foreach($Hora in $adds){
     If ($Hora.EntryType -eq "information") {$TextBoxInfo.text = $textBoxInfo.text + "OK - " + $Hora.TimeGenerated + " " + $Hora.EntryType + " " + $Hora.message + "`r`n"}
     If ($Hora.EntryType -eq "warning") {$TextBoxInfo.text = $textBoxInfo.text + "WARNING - " + $Hora.TimeGenerated + " " + $Hora.EntryType + " " + $Hora.message + "`r`n"}
     If ($Hora.EntryType -eq "error") {$TextBoxInfo.text = $textBoxInfo.text + "KO - " + $Hora.TimeGenerated + " " + $Hora.EntryType + " " + $Hora.message + "`r`n"}
     If ($Hora.EntryType -eq "critical") {$TextBoxInfo.text = $textBoxInfo.text + "KO - " + $Hora.TimeGenerated + " " + $Hora.EntryType + " " + $Hora.message + "`r`n"}
     }
}else{
    $TextBoxInfo.Text = "Cal introduir servidor"
    }
}

function PRINT($Servidor){
If ($Servidor){
    $IsPrintServer = Get-WindowsFeature -name Print-Server -ComputerName $Servidor
    If ($IsPrintServer.InstallState -eq "Installed"){
        $PRINT = Get-EventLog -newest 10 -logname System -Source "LT2C_PRINT" -ComputerName $Servidor
        foreach($Hora1 in $PRINT){
            if ($Hora1.EntryType -eq "error") {$TextBoxInfo.text = $textBoxInfo.text + "KO - " + $Hora1.TimeGenerated + " " + $Hora1.EntryType + " " + $Hora1.message + "`r`n"}
            if ($Hora1.EntryType -eq "warning") {$TextBoxInfo.text = $textBoxInfo.text + "WARNING - " + $Hora1.TimeGenerated + " " + $Hora1.EntryType + " " + $Hora1.message + "`r`n"}
            if ($Hora1.EntryType -eq "information") {$TextBoxInfo.text = $textBoxInfo.text + "OK - " + $Hora1.TimeGenerated + " " + $Hora1.EntryType + " " + $Hora1.message + "`r`n"}
            if ($Hora1.EntryType -eq "critical") {$TextBoxInfo.text = $textBoxInfo.text + "KO - " + $Hora1.TimeGenerated + " " + $Hora1.EntryType + " " + $Hora1.message + "`r`n"}
        }
    }
    Else
    {
    $TextBoxInfo.Text = "El Servidor no es PrintServer"
    }
}else{
    $TextBoxInfo.Text = "Cal introduir servidor"
    }
}

function ERRORS($Servidor){ 
If ($Servidor){
    $CapturaErrors = Get-EventLog -LogName System -EntryType Error -ComputerName $Servidor -Newest 5
    ForEach ($EventError in $CapturaErrors){
        $TextBoxInfo.text = $textBoxInfo.text + $EventError.TimeGenerated + " " + $EventError.Source + " " + $Eventerror.Message.Substring(0,60) + "`r`n"
    }
}else{
    $TextBoxInfo.Text = "Cal introduir servidor"
    }
}



#MOSTRAR FORMULARI
$Form.ShowDialog()

#----------------------------------------------------------------------------------------------------------

