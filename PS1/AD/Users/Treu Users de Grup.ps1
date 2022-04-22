$extract = Get-Content c:\gava.txt

Foreach ($Valor in $extract){
        
        #write-host "Elimino $valor del grupo"
        Remove-ADGroupMember -Identity 'lt2c_appdis_Temis210' -Members $valor
        Remove-ADGroupMember -Identity 'lt2c_appdis_Temis210_Nadiu' -Members $valor -Confirm:$false  
}
