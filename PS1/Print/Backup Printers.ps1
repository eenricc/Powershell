# RUTA ON DESAR BACKUP
$Ruta_Desti = "C:\users\enric.ferrer\desktop\Desti"

# COPIA DE LES 2 CARPETES
Copy-Item -Path "c:\windows\system32\spool\drivers" -Destination $Ruta_Desti -Recurse -Force
Copy-Item -Path "c:\windows\system32\spool\prtprocs" -Destination $Ruta_Desti -Recurse -Force

# EXPORTACIO CLAUS REGISTRE
reg EXPORT "HKLM\System\CurrentControlSet\Control\Print" "$Ruta_Desti\CCSPrint.reg"
reg EXPORT "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Print" "$Ruta_Desti\Print.reg"
reg EXPORT "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Ports" "$Ruta_Desti\Ports.reg"
