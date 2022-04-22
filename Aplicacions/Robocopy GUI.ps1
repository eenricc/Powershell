[System.Windows.Forms.Application]::EnableVisualStyles()
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework

#-----------------------------------------------------------------------------------
# FORMULARI
#-----------------------------------------------------------------------------------
$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '644,488'
$Form.text                       = "ROBOCOPY BACKUP"
$Form.TopMost                    = $false
$Form.MinimizeBox                = $false
$Form.MaximizeBox                = $false
$Form.FormBorderStyle            = 'FixedDialog'
$Form.StartPosition              = "CenterScreen"
$Form.Icon                       = $null

#------------- ETIQUETA ORIGEN/DESTI/COPIA -------------
$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Origen:"
$Label1.AutoSize                 = $true
$Label1.width                    = 570
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(30,20)
$Label1.Font                     = 'Calibri,11'

$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "Destí:"
$Label2.AutoSize                 = $true
$Label2.width                    = 570
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(30,53)
$Label2.Font                     = 'Calibri,11'

$Label3                          = New-Object system.Windows.Forms.Label
$Label3.text                     = "Tipus de còpia"
$Label3.AutoSize                 = $true
$Label3.width                    = 25
$Label3.height                   = 10
$Label3.location                 = New-Object System.Drawing.Point(460,14)
$Label3.Font                     = 'Calibri,11'

#------------- TEXTBOX ORIGEN/DESTI -------------
$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.width                  = 241
$TextBox1.height                 = 15
$TextBox1.location               = New-Object System.Drawing.Point(83,18)
$TextBox1.Font                   = 'Calibri,11'

$TextBox2                        = New-Object system.Windows.Forms.TextBox
$TextBox2.multiline              = $false
$TextBox2.width                  = 241
$TextBox2.height                 = 20
$TextBox2.location               = New-Object System.Drawing.Point(83,50)
$TextBox2.Font                   = 'Calibri,11'

#------------- BOTONS CERCA -------------
$Button2                         = New-Object system.Windows.Forms.Button
$Button2.text                    = "Cerca"
$Button2.width                   = 60
$Button2.height                  = 25
$Button2.location                = New-Object System.Drawing.Point(334,18)
$Button2.Font                    = 'Calibri,11'
$Button2.Add_Click({$TextBox1.text = Get-Folderlocation})

$Button3                         = New-Object system.Windows.Forms.Button
$Button3.text                    = "Cerca"
$Button3.width                   = 60
$Button3.height                  = 25
$Button3.location                = New-Object System.Drawing.Point(334,50)
$Button3.Font                    = 'Calibri,11'
$Button3.Add_Click({$TextBox2.text = Get-Folderlocation})

#------------- TEXT OUTPUT -------------
$TextBox3                        = New-Object system.Windows.Forms.TextBox
$TextBox3.multiline              = $true
$TextBox3.width                  = 583
$TextBox3.height                 = 327
$TextBox3.location               = New-Object System.Drawing.Point(30,93)
$TextBox3.Font                   = 'Calibri,11'
$TextBox3.ScrollBars             = "Both"

#------------- BOTO BACKUP -------------
$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "BACKUP"
$Button1.width                   = 460
$Button1.height                  = 30
$Button1.location                = New-Object System.Drawing.Point(28,439)
$Button1.Font                    = 'Calibri,11'
$Button1.Add_Click({validaCarpeta})

#------------- TIPUS COPIA -------------
$RadioButton1                    = New-Object system.Windows.Forms.RadioButton
$RadioButton1.text               = "Mirall"
$RadioButton1.AutoSize           = $true
$RadioButton1.width              = 104
$RadioButton1.height             = 20
$RadioButton1.location           = New-Object System.Drawing.Point(460,35)
$RadioButton1.Font               = 'Calibri,11'
$RadioButton1.Add_Click({alerta})

$RadioButton2                    = New-Object system.Windows.Forms.RadioButton
$RadioButton2.text               = "Afegir al destí"
$RadioButton2.AutoSize           = $true
$RadioButton2.width              = 104
$RadioButton2.height             = 20
$RadioButton2.location           = New-Object System.Drawing.Point(460,58)
$RadioButton2.Font               = 'Calibri,11'
$RadioButton2.Checked            = $true
$RadioButton2.Add_Click({info})

#------------- BOTO NETEJA -------------
$Button4                         = New-Object system.Windows.Forms.Button
$Button4.text                    = "Neteja"
$Button4.width                   = 104
$Button4.height                  = 30
$Button4.location                = New-Object System.Drawing.Point(509,439)
$Button4.Font                    = 'Calibri,11'
$Button4.Add_Click({Neteja})

$Form.controls.AddRange(@($Label1,$TextBox1,$Label2,$TextBox2,$Button1,$TextBox3,$RadioButton1,$RadioButton2,$Button2,$Button3,$Button4,$Label3))

#-----------------------------------------------------------------------------------
# FUNCIONS
#-----------------------------------------------------------------------------------

function get-Folderlocation(){
    $app = New-Object -ComObject Shell.Application
    $folder = $app.BrowseForFolder(0, "Selecciona carpeta", 0, "")
    if ($folder) { $selectedDirectory = $folder.Self.Path } else { $selectedDirectory = '' }
    return $selectedDirectory
}

function validaCarpetes{
    If ($TextBox1.textlength -eq 0 -or $TextBox2.textlength -eq 0 -or (!(test-path -path $TextBox1.text)) -or(!(test-path -path $TextBox2.text))){
        [System.Windows.MessageBox]::Show('Cal omplenar els camps Origen/Destí amb dades correctes','ERROR','OK','Error')
    }else{
        If ($RadioButton1.Checked -eq $true){ backup("mirall") }
        If ($RadioButton2.Checked -eq $true){ backup("afegint") }
    }
}

function backup($comanda){
    $origen = $TextBox1.text
    $desti = $TextBox2.text
    If ($comanda -eq "mirall"){robocopy "$origen" "$desti" /MIR /FFT /Z /R:2 /W:5 | foreach {$TextBox3.AppendText($_ + "`r`n")}}
    If ($comanda -eq "afegint"){robocopy "$origen" "$desti" /E /FFT /Z /R:2 /W:5 | foreach {$TextBox3.AppendText($_ + "`r`n")}}       
}


function Neteja{
    $textBox3.Clear()
}

function alerta{
[System.Windows.MessageBox]::Show('Copia a la carpeta DESTÍ el contingut a ORIGEN.' +"`r`n`r`n"+ 'IMPORTANT: La copia mirall deixa la carpeta destí igual que origen. Si existeixen arxius a destí que no són a origen, els eliminarà.','ALERTA','OK','Warning')
}

function info{
[System.Windows.MessageBox]::Show('Afegeix a la carpeta DESTÍ el contingut a ORIGEN','INFO','OK','Information')
}

#-----------------------------------------------------------------------------------
# FUNCIONS
#-----------------------------------------------------------------------------------
[void]$Form.ShowDialog()