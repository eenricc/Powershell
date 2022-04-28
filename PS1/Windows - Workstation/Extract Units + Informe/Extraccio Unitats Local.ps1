$unitats = Get-WmiObject -Class Win32_logicaldisk -Filter "DriveType = 4"
$data = Get-Date -format "ddMMyy_hhmm"
$nom_log = "$env:computername" + "_" + "$env:username" + "_" + $data + ".log"
#Ubicació local del PC on s'executa on desarem el .log
$log_ruta = "c:\temp\"
#Ubicació de carpeta de xarxa on desarem el .log de tots els equips
$log_xarxa = "\\10.10.10.29\Publica\ts_data\"

function crea_log{
    Foreach ($unit in $unitats){
        $log = $env:computername + "`t" + $env:username + "`t" + $env:USERDNSDOMAIN + "`t" + $unit.DeviceID + "`t" + $unit.ProviderName
        Out-File -filepath "$log_ruta $nom_log" -InputObject $log -Append
    }
    #Copy-Item "$log_ruta$nom_log" -Destination $log_xarxa
}

function carpeta{
    if (test-path $log_ruta){
        crea_log
    }else{
        New-item -path $log_ruta –type directory
        crea_log
    }
}

carpeta