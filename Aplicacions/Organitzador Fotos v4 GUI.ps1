[System.Windows.Forms.Application]::EnableVisualStyles()
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework

#-------------------------------------------------------------------------------------------------------------
# FORMULARI
#-------------------------------------------------------------------------------------------------------------

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,180'
$Form.text                       = "ORGANITZADOR DE FOTOS"
$Form.TopMost                    = $false
$Form.MinimizeBox                = $false
$Form.MaximizeBox                = $false
$Form.FormBorderStyle            = 'FixedDialog'
$Form.StartPosition              = "CenterScreen"
$Form.Icon                       = $null

#------------------------ ETIQUETES -----------------------
$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Origen:"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(21,25)
$Label1.Font                     = 'Calibri,11'

$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "Destí:"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(21,57)
$Label2.Font                     = 'Calibri,11'

#----------------------- TEXTBOX ORIGEN/DESTI -----------------------
$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.width                  = 234
$TextBox1.height                 = 20
$TextBox1.location               = New-Object System.Drawing.Point(74,23)
$TextBox1.Font                   = 'Calibri,11'

$TextBox2                        = New-Object system.Windows.Forms.TextBox
$TextBox2.multiline              = $false
$TextBox2.width                  = 233
$TextBox2.height                 = 20
$TextBox2.location               = New-Object System.Drawing.Point(74,55)
$TextBox2.Font                   = 'Calibri,11'

#----------------------- BOTONS BROWSE -----------------------
$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "Cerca"
$Button1.width                   = 60
$Button1.height                  = 27
$Button1.location                = New-Object System.Drawing.Point(320,22)
$Button1.Font                    = 'Calibri,11'
$Button1.Add_Click({$TextBox1.text = Get-Folderlocation})

$Button2                         = New-Object system.Windows.Forms.Button
$Button2.text                    = "Cerca"
$Button2.width                   = 60
$Button2.height                  = 27
$Button2.location                = New-Object System.Drawing.Point(320,54)
$Button2.Font                    = 'Calibri,11'
$Button2.Add_Click({$TextBox2.text = Get-Folderlocation})

#----------------------- BOTO ORGANITZA -----------------------
$Button3                         = New-Object system.Windows.Forms.Button
$Button3.text                    = "ORGANITZA"
$Button3.width                   = 288
$Button3.height                  = 30
$Button3.location                = New-Object System.Drawing.Point(16,140)
$Button3.Font                    = 'Calibri,11'
$Button3.Add_Click({validaCarpeta})

#----------------------- BOTO CLEAR -----------------------
$Button4                         = New-Object system.Windows.Forms.Button
$Button4.text                    = "Neteja"
$Button4.width                   = 60
$Button4.height                  = 30
$Button4.location                = New-Object System.Drawing.Point(324,140)
$Button4.Font                    = 'Calibri,11'
$Button4.Add_Click({Neteja})

#----------------------- PROGRESSBAR ------------------------
$ProgressBar1                    = New-Object system.Windows.Forms.ProgressBar
$ProgressBar1.width              = 366
$ProgressBar1.height             = 30
$ProgressBar1.location           = New-Object System.Drawing.Point(17,93)

$Label3                          = New-Object system.Windows.Forms.Label
$Label3.AutoSize                 = $false
$Label3.width                    = 366
$Label3.height                   = 18
$Label3.location                 = New-Object System.Drawing.Point(17,123)
$Label3.Font                     = 'Calibri,10'
$Label3.TextAlign                = 'MiddleCenter'

$Form.controls.AddRange(@($Label1,$Label2,$Label3,$TextBox1,$TextBox2,$Button1,$Button2,$Button3,$Button4,$ProgressBar1))

#-------------------------------------------------------------------------------------------------------------
# FUNCIONS
#-------------------------------------------------------------------------------------------------------------

function get-Folderlocation{
    $app = New-Object -ComObject Shell.Application
    $folder = $app.BrowseForFolder(0, "Selecciona carpeta", 0, "")
    if ($folder) { $selectedDirectory = $folder.Self.Path } else { $selectedDirectory = '' }
    return $selectedDirectory
}

function validaCarpeta{
    If ($TextBox1.textlength -eq 0 -or $TextBox2.textlength -eq 0 -or (!(test-path -path $TextBox1.text)) -or(!(test-path -path $TextBox2.text))){
        [System.Windows.MessageBox]::Show('Cal omplenar els camps Origen/Destí amb dades correctes','ERROR','OK','Error')
    }else{
        organitza
    }
}

function organitza{
    $origen = $textbox1.text
    $desti = $textbox2.text
    $jpgnoinfo = "Imatges sense Metadades"
    $video = "Video"
    $videonoinfo = "Video sense Metadates"
    $nofiltrat = "Arxius no filtrats"
    $files = Get-ChildItem $origen -recurse | Where-Object{!($_.PSIsContainer)}
    $ProgressBarCount = 1
    $ProgressBar1.Maximum = $files.Count    

    Foreach ($file in $files){      
        $resultat = $null
        $extensio = [System.IO.Path]::getextension($file)
        $resultat = Switch ($extensio) {
            default {"ALTRES"}
            .jpg {"JPG"}
            .mp4 {"VIDEO"}
            .avi {"VIDEO"}
        }
    
        #ARXIUS JPG
        If ($resultat -eq "JPG"){
            $pic = New-Object System.Drawing.Bitmap($file.fullname)
            Try{
                $img_prop = $pic.GetPropertyItem(36867).Value 
                $img_string = [System.Text.Encoding]::ASCII.GetString($img_prop)
                $any = $img_string.Substring(0,4)
                $mes = $img_string.Substring(5,2)
                $mesNom = Switch ($mes){
                    "01" {"01 - Gener"}
                    "02" {"02 - Febrer"}
                    "03" {"03 - Març"}
                    "04" {"04 - Abril"}
                    "05" {"05 - Maig"}
                    "06" {"06 - Juny"}
                    "07" {"07 - Juliol"}
                    "08" {"08 - Agost"}
                    "09" {"09 - Setembre"}
                    "10" {"10 - Octubre"}
                    "11" {"11 - Novembre"}
                    "12" {"12 - Desembre"}
                }
                If (!(Test-Path -path "$desti\$any")) {New-Item "$desti\$any" -Type Directory}
                If (!(Test-Path -path "$desti\$any\$mesNom")) {New-Item "$desti\$any\$mesNom" -Type Directory}
                Copy-Item -path $file.fullname -destination $desti\$any\$mesnom -Recurse -Force
                $Label3.Text = $file
                $Label3.Refresh()
                
            } Catch {
                If (!(Test-Path -path "$desti\$JPGnoinfo")) {New-Item "$desti\$JPGnoinfo" -Type Directory}
                Copy-Item -path $file.fullname -destination $desti\$JPGnoinfo -Recurse -Force
                $Label3.Text = $file
                $Label3.Refresh()
            }
        }

        #ARXIUS DE VIDEO
        If ($resultat -eq "VIDEO"){
            $dadesVideo = Get-Item $file.fullname
            Try{
                $ExractMes = $dadesVideo.LastWriteTime.Month
                $ExtractAny = $dadesVideo.LastWriteTime.year
                $NomMes = Switch($ExractMes){
                        "1" {"01 - Gener"}
                        "2" {"02 - Febrer"}
                        "3" {"03 - Març"}
                        "4" {"04 - Abril"}
                        "5" {"05 - Maig"}
                        "6" {"06 - Juny"}
                        "7" {"07 - Juliol"}
                        "8" {"08 - Agost"}
                        "9" {"09 - Setembre"}
                        "10" {"10 - Octubre"}
                        "11" {"11 - Novembre"}
                        "12" {"12 - Desembre"}
                }
                If (!(Test-Path -path "$desti\$ExtractAny")) {New-Item "$desti\$ExtractAny" -Type Directory}
                If (!(Test-Path -path "$desti\$ExtractAny\$NomMes")) {New-Item "$desti\$ExtractAny\$NomMes" -Type Directory}
                If (!(Test-Path -path "$desti\$ExtractAny\$NomMes\$video")) {New-Item "$desti\$ExtractAny\$NomMes\$video" -Type Directory}
                Copy-Item -path $file.fullname -destination $desti\$ExtractAny\$NomMes\$video -Recurse -Force
                $Label3.Text = $file
                $Label3.Refresh()  
            }Catch{
                If (!(Test-Path -path "$desti\$videonoinfo")) {New-Item "$desti\$videonoinfo" -Type Directory}
                Copy-Item -path $file.fullname -destination $desti\$videonoinfo -Recurse -Force
                $Label3.Text = $file
                $Label3.Refresh()
            }       
        }

        #ARXIS NO FILTRATS
        If ($resultat -eq "ALTRES"){
            If (!(Test-Path -path "$desti\$nofiltrat")) {New-Item "$desti\$nofiltrat" -Type Directory}
                Copy-Item -path $file.fullname -destination $desti\$nofiltrat -Recurse -Force
                $Label3.Text = $file
                $Label3.Refresh()            
        }
    
        #INFO BARRA PROGRES
        $ProgressBar1.Value = $ProgressBarCount
        $ProgressBarCount = $ProgressBarCount + 1
    }

    If ($files.count -eq "0"){[System.Windows.MessageBox]::Show('No hi han arxius a la carpeta origen','Organitzador de Fotos','OK','Information')}else{[System.Windows.MessageBox]::Show('Copia Finalitzada', 'Organitzador de Fotos', 'OK', 'Information')}
    $ProgressBar1.Value = 0
    $Label3.Text = ""
    $Label3.Refresh()    
}  

function Neteja{
    $textBox1.Clear()
    $textBox2.Clear()   
}

#-------------------------------------------------------------------------------------------------------------
# MOSTRA FORMULARI
#-------------------------------------------------------------------------------------------------------------
[void]$Form.ShowDialog()