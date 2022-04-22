[System.Windows.Forms.Application]::EnableVisualStyles()
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework

#----------------------------------------------------------------------------------------------------------
# FORMULARI
#---------------------------------------------------------------------------------------------------------- 
$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,240'
$Form.text                       = "COPIA-MOU EXTENSIONS"
$Form.TopMost                    = $false 
$Form.MinimizeBox                = $false
$Form.MaximizeBox                = $false
$Form.FormBorderStyle            = 'FixedDialog'
$Form.StartPosition              = "CenterScreen"
$Form.Icon                       = $null

#------------- ETIQUETES -------------
$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Origen:"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(27,32)
$Label1.Font                     = 'Calibri,11'

$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "Destí:"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(27,65)
$Label2.Font                     = 'Calibri,11'

$Label3                          = New-Object system.Windows.Forms.Label
$Label3.text                     = "Extensió:"
$Label3.AutoSize                 = $true
$Label3.width                    = 25
$Label3.height                   = 10
$Label3.location                 = New-Object System.Drawing.Point(27,98)
$Label3.Font                     = 'Calibri,11'

$Label5                          = New-Object system.Windows.Forms.Label
$Label5.text                     = "Tipus:"
$Label5.AutoSize                 = $true
$Label5.width                    = 25
$Label5.height                   = 10
$Label5.location                 = New-Object System.Drawing.Point(27,131)
$Label5.Font                     = 'Calibri,11'

#------------- TEXTBOX ORIGEN / DESTI / EXTENSIO-------------
$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.width                  = 216
$TextBox1.height                 = 15
$TextBox1.location               = New-Object System.Drawing.Point(88,30)
$TextBox1.Font                   = 'Calibri,11'

$TextBox2                        = New-Object system.Windows.Forms.TextBox
$TextBox2.multiline              = $false
$TextBox2.width                  = 216
$TextBox2.height                 = 15
$TextBox2.location               = New-Object System.Drawing.Point(88,62)
$TextBox2.Font                   = 'Calibri,11'

$TextBox3                        = New-Object system.Windows.Forms.TextBox
$TextBox3.multiline              = $false
$TextBox3.width                  = 50
$TextBox3.height                 = 20
$TextBox3.location               = New-Object System.Drawing.Point(88,94)
$TextBox3.Font                   = 'Calibri,11'

#------------- BOTONS BROWSE -------------
$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "Cerca"
$Button1.width                   = 60
$Button1.height                  = 27
$Button1.location                = New-Object System.Drawing.Point(315,29)
$Button1.Font                    = 'Calibri,11'
$Button1.Add_Click({$TextBox1.text = Get-Folderlocation})

$Button2                         = New-Object system.Windows.Forms.Button
$Button2.text                    = "Cerca"
$Button2.width                   = 60
$Button2.height                  = 27
$Button2.location                = New-Object System.Drawing.Point(315,61)
$Button2.Font                    = 'Calibri,11'
$Button2.Add_Click({$TextBox2.text = Get-Folderlocation})

#------------- BOTO COPIA -------------
$Button3                         = New-Object system.Windows.Forms.Button
$Button3.text                    = "INICIA"
$Button3.width                   = 270
$Button3.height                  = 30
$Button3.location                = New-Object System.Drawing.Point(23,200)
$Button3.Font                    = 'Calibri,11'
$Button3.Add_Click({validaCarpetes})

#------------- BOTO CLEAR -------------
$Button4                         = New-Object system.Windows.Forms.Button
$Button4.text                    = "Neteja"
$Button4.width                   = 73
$Button4.height                  = 30
$Button4.location                = New-Object System.Drawing.Point(300,200)
$Button4.Font                    = 'Calibri,11'
$Button4.Add_Click({Neteja})

#------------- SELECTOR -------------
$RadioButton1                    = New-Object system.Windows.Forms.RadioButton
$RadioButton1.text               = "Copia"
$RadioButton1.AutoSize           = $true
$RadioButton1.width              = 104
$RadioButton1.height             = 20
$RadioButton1.location           = New-Object System.Drawing.Point(88,131)
$RadioButton1.Font               = 'Microsoft Sans Serif,10'
$RadioButton1.Checked            = $true

$RadioButton2                    = New-Object system.Windows.Forms.RadioButton
$RadioButton2.text               = "Mou"
$RadioButton2.AutoSize           = $true
$RadioButton2.width              = 104
$RadioButton2.height             = 20
$RadioButton2.location           = New-Object System.Drawing.Point(160,131)
$RadioButton2.Font               = 'Microsoft Sans Serif,10'

#----------------------- PROGRESSBAR ------------------------
$ProgressBar1                    = New-Object system.Windows.Forms.ProgressBar
$ProgressBar1.width              = 349
$ProgressBar1.height             = 34
$ProgressBar1.location           = New-Object System.Drawing.Point(24,160)

#----------------------- LABEL INFO ------------------------
$Label4                          = New-Object system.Windows.Forms.Label
$Label4.AutoSize                 = $false
$Label4.width                    = 220
$Label4.height                   = 20
$Label4.location                 = New-Object System.Drawing.Point(153,97)
$Label4.Font                     = 'Calibri,10'
$Label4.TextAlign                = 'MiddleCenter'

$Form.controls.AddRange(@($Label1,$TextBox1,$Label2,$TextBox2,$Label3,$TextBox3,$Button1,$Button2,$Button3,$Button4,$ProgressBar1,$Label4,$RadioButton1,$RadioButton2,$Label5))

#----------------------------------------------------------------------------------------------------------
# FUNCIONS
#----------------------------------------------------------------------------------------------------------
function get-Folderlocation{
    $app = New-Object -ComObject Shell.Application
    $folder = $app.BrowseForFolder(0, "Selecciona carpeta", 0, "")
    if ($folder) { $selectedDirectory = $folder.Self.Path } else { $selectedDirectory = '' }
    return $selectedDirectory
}

function validaCarpetes{
    If ($TextBox1.textlength -eq 0 -or $TextBox2.textlength -eq 0 -or $TextBox3.textlength -eq 0 -or (!(test-path -path $TextBox1.text)) -or(!(test-path -path $TextBox2.text))){
        [System.Windows.MessageBox]::Show('Cal omplenar els camps Origen/Destí/Extensió amb dades correctes','ERROR','OK','Error')
    }else{
        If ($RadioButton1.Checked -eq $true){copiaExtensions("Copia")}
        If ($RadioButton2.Checked -eq $true){copiaExtensions("Mou")}    
    }
}

function copiaExtensions($comanda){
    $origen = $TextBox1.text
    $desti = $TextBox2.text
    $extensio = "*." + $TextBox3.text
    $Dir = get-childitem $origen -recurse -Filter $extensio
    $ProgressBarCount = 1
    $ProgressBar1.Maximum = $Dir.Count   
    $i = 0
    Foreach ($arxiu in $Dir){      
        If ((Test-Path $desti\$arxiu) -eq $true){
            $newname = $arxiu.BaseName + " (D" + $i + ")" + $arxiu.Extension
            If ($comanda -eq "Copia"){ Copy-Item $arxiu.FullName -Destination $desti\$newname }
            If ($comanda -eq "Mou"){ Move-Item $arxiu.FullName -Destination $desti\$newname }
            $i +=1
        }else{
            If ($comanda -eq "Copia"){ Copy-Item $arxiu.FullName -Destination $desti }  
            If ($comanda -eq "Mou"){ Move-Item $arxiu.FullName -Destination $desti }  
        }              
        $ProgressBar1.Value = $ProgressBarCount
        $ProgressBarCount = $ProgressBarCount + 1
        $Label4.Text = $arxiu
        $Label4.Refresh()
    }
    If ($Dir.Count -eq "0"){
        [System.Windows.MessageBox]::Show('No hi han arxius amb extensió indicada a origen','Copia Extensions','OK','Information')
    }else{
        [System.Windows.MessageBox]::Show("Acció finalitzada","$comanda Extensions",'OK','Information')
    }
    $ProgressBar1.Value = 0
    $Label4.Text = ""
    $Label4.Refresh()
        
}

function Neteja{
    $textBox1.Clear()
    $textBox2.Clear()
    $textBox3.Clear()
}

#----------------------------------------------------------------------------------------------------------
# MOSTRAR FORMULARI
#----------------------------------------------------------------------------------------------------------
[void]$Form.ShowDialog()
