Add-Type -AssemblyName System.Windows.Forms
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = New-Object System.Drawing.Point(606,274)
$form.FormBorderStyle            = 'FixedDialog'
$Form.text                       = "Baja usuarios v1.0"
$form.StartPosition              = "CenterScreen"
$Form.MinimizeBox                = $False
$Form.MaximizeBox                = $False
$Form.TopMost                    = $false

$LabelUsuario                    = New-Object system.Windows.Forms.Label
$LabelUsuario.text               = "SamAccountName:"
$LabelUsuario.AutoSize           = $true
$LabelUsuario.width              = 25
$LabelUsuario.height             = 10
$LabelUsuario.location           = New-Object System.Drawing.Point(424,25)
$LabelUsuario.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',8)

$TextBoxUsuario                  = New-Object system.Windows.Forms.TextBox
$TextBoxUsuario.multiline        = $false
$TextBoxUsuario.width            = 100
$TextBoxUsuario.height           = 20
$TextBoxUsuario.location         = New-Object System.Drawing.Point(423,43)
$TextBoxUsuario.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',8)

$ButtonVerifica                  = New-Object system.Windows.Forms.Button
$ButtonVerifica.text             = "Verifica"
$ButtonVerifica.width            = 60
$ButtonVerifica.height           = 19
$ButtonVerifica.location         = New-Object System.Drawing.Point(534,44)
$ButtonVerifica.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',8)
$ButtonVerifica.add_click({verificaUserAD})

$CheckBoxAutorespuesta           = New-Object system.Windows.Forms.CheckBox
$CheckBoxAutorespuesta.text      = "Autorespuesta en el correo"
$CheckBoxAutorespuesta.AutoSize  = $false
$CheckBoxAutorespuesta.width     = 160
$CheckBoxAutorespuesta.height    = 20
$CheckBoxAutorespuesta.location  = New-Object System.Drawing.Point(424,73)
$CheckBoxAutorespuesta.Enabled   = $false
$CheckBoxAutorespuesta.Font      = New-Object System.Drawing.Font('Microsoft Sans Serif',8)

$CheckBoxRedireccion             = New-Object system.Windows.Forms.CheckBox
$CheckBoxRedireccion.text        = "Redirección del correo"
$CheckBoxRedireccion.AutoSize    = $false
$CheckBoxRedireccion.width       = 160
$CheckBoxRedireccion.height      = 20
$CheckBoxRedireccion.location    = New-Object System.Drawing.Point(424,97)
$CheckBoxRedireccion.Enabled     = $false
$CheckBoxRedireccion.Font        = New-Object System.Drawing.Font('Microsoft Sans Serif',8)
$CheckBoxRedireccion.Add_Click{(checkRedireccion)}

$ButtonTicket                    = New-Object system.Windows.Forms.Button
$ButtonTicket.text               = "Ticket"
$ButtonTicket.width              = 60
$ButtonTicket.height             = 18
$ButtonTicket.location           = New-Object System.Drawing.Point(536,121)
$ButtonTicket.Enabled            = $false
$ButtonTicket.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',8)
$ButtonTicket.Add_Click{(AddTicket)}

$ButtonMail                      = New-Object system.Windows.Forms.Button
$ButtonMail.text                 = "Mail"
$ButtonMail.width                = 60
$ButtonMail.height               = 17
$ButtonMail.location             = New-Object System.Drawing.Point(536,147)
$ButtonMail.Enabled              = $false
$ButtonMail.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',8)
$ButtonMail.Add_click{(AddMail)}

$TextBoxTicket                   = New-Object system.Windows.Forms.TextBox
$TextBoxTicket.multiline         = $false
$TextBoxTicket.width             = 100
$TextBoxTicket.height            = 20
$TextBoxTicket.enabled           = $true
$TextBoxTicket.ReadOnly          = $true
$TextBoxTicket.location          = New-Object System.Drawing.Point(424,120)
$TextBoxTicket.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',8)

$TextBoxMail                     = New-Object system.Windows.Forms.TextBox
$TextBoxMail.multiline           = $false
$TextBoxMail.width               = 100
$TextBoxMail.height              = 20
$TextBoxMail.ReadOnly          = $true
$TextBoxMail.location            = New-Object System.Drawing.Point(424,146)
$TextBoxMail.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',8)

$TextBoxInfo                     = New-Object system.Windows.Forms.TextBox
$TextBoxInfo.multiline           = $true
$TextBoxInfo.width               = 402
$TextBoxInfo.height              = 233
$TextBoxInfo.location            = New-Object System.Drawing.Point(9,22)
$TextBoxInfo.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',9)

$ButtonEjecutaBaja               = New-Object system.Windows.Forms.Button
$ButtonEjecutaBaja.text          = "Realizar Baja" 
$ButtonEjecutaBaja.width         = 160
$ButtonEjecutaBaja.height        = 30
$ButtonEjecutaBaja.Enabled       = $false
$ButtonEjecutaBaja.location      = New-Object System.Drawing.Point(424,180)
$ButtonEjecutaBaja.Font          = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$ButtonEjecutaBaja.add_click{(EjecutaBaja)}

$ButtonNueva                      = New-Object system.Windows.Forms.Button
$ButtonNueva.text                 = "Nueva"
$ButtonNueva.width                = 160
$ButtonNueva.height               = 30
$ButtonNueva.location             = New-Object System.Drawing.Point(424,224)
$ButtonNueva.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$ButtonNueva.Enabled              = $False
$ButtonNueva.add_click({Nueva})


$Form.controls.AddRange(@($TextBoxUsuario,$LabelUsuario,$CheckBoxRedireccion,$CheckBoxAutorespuesta,$ButtonVerifica,$ButtonTicket,$ButtonMail,$TextBoxTicket,$TextBoxMail,$TextBoxInfo,$ButtonEjecutaBaja,$ButtonNueva))

#FUNCIONES

Function verificaUserAD {
    Try {
        $global:checkUser = (Get-ADUser $TextBoxUsuario.text).name
        $ConfirmacionBajaUsuario =  [System.Windows.MessageBox]::Show("Quieres realizar la baja del usaurio $checkUser","Baja de Usuario","YesNo","Information")
            switch  ($ConfirmacionBajaUsuario) {
                "Yes" {
                    $TextBoxUsuario.ReadOnly = $true
                    $ButtonVerifica.enabled = $false
                    $CheckBoxAutorespuesta.Enabled = $True
                    $CheckBoxRedireccion.Enabled = $True
                    $ButtonEjecutaBaja.Enabled = $True
                } 
                
                "No" {
                    $TextBoxUsuario.text = ""
                }
            }
   
    } Catch {
        [System.Windows.MessageBox]::Show("El usuario indicado no existe en AD","Baja de Usuario","Ok","Error")
    }
}

Function checkRedireccion {
    [System.Windows.MessageBox]::Show("La redirección de correo debe ser aprobada por COMITE.ETICA.`n Se deberan rellenar los dos campos a continuación con 'Numero de Ticket' y 'Correo de redirección'","Redirección de correos","Ok","Warning")
    $ButtonTicket.Enabled = $True
    $ButtonMail.Enabled = $True
}

Function AddTicket{
    $AddTicket = [Microsoft.VisualBasic.Interaction]::InputBox("Introduce el número de ticket", "Ticket")
    $TextBoxTicket.Text = $AddTicket
}

Function AddMail{
    $AddMail = [Microsoft.VisualBasic.Interaction]::InputBox("Introduce el correo electrónico completo al que redireccionar", "Redirección de correo")
    $TextBoxMail.Text = $AddMail
}

Function EjecutaBaja{
    If ($CheckBoxAutorespuesta.CheckState -eq $true){ $Autorespuesta = "Si" } else {$Autorespuesta = "No"}
    If ($CheckBoxRedireccion.CheckState -eq $true){ $Redireccion = "Si" } else {$Redireccion = "No"}
    If ($CheckBoxRedireccion.CheckState -eq $true -and ($TextBoxTicket.text -eq "" -or $TextBoxMail.text -eq "")){
        [System.Windows.MessageBox]::Show("Los campos de Ticket y Mail no pueden estar vacios","Error","Ok","Warning")
    } else {
        $TicketText = $TextBoxTicket.Text
        $MailText = $Textboxmail.Text
        $EjecutarBajaUsuario = [System.Windows.MessageBox]::Show("Se va a realizar la baja con los siguientes datos:`n`n Usuario: $global:checkUser  `n Autorespuesta: $autorespuesta `n Redirección de correo: $Redireccion ","Confirmar Baja","YesNo","Information")
        Switch ($EjecutarBajaUsuario){
            "No"{}
            "Yes"{
                $TextBoxInfo.AppendText("Baja de usuario: $global:checkUser`n")
                $TextBoxInfo.AppendText("Autorespuesta de correo: $Autorespuesta`n")
                $TextBoxInfo.AppendText("Redirección de correo: $Redireccion`n")
                If ($Redireccion -eq "Si") {$TextBoxInfo.AppendText("Ticket: $TicketText // Mail de redirección: $MailText`n")}
                $TextBoxInfo.AppendText("Iniciando Baja...`n")
                ##### AQUI VA EL SCRIPT DE CLIENT ###############
        }
    }
    }
}

Function Nueva {
    
}

#EJECUTAR FORMULARIO
$Form.ShowDialog() | Out-Null