Write-host "Numero del 0 al 6:"
$Text = read-host 

switch ($Text){
    Default { $result = 'Unknown' }
    0 { $result = 'Has posat 0'}
    1 { $result = 'Has posat 1'}
    2 { $result = 'Has posat 2'}
    3 { $result = 'Has posat 3'}
    4 { $result = 'Has posat 4'}
    5 { $result = 'Has posat 5'}
    6 { $result = 'Has posat 6'}
}

Write-host $result


#########################
# OPCIO AMB MES DADES
#########################

$ConfirmacionBajaUsuario =  [System.Windows.MessageBox]::Show("Quieres realizar la baja del usaurio","Baja de Usuario","YesNo","Information")

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