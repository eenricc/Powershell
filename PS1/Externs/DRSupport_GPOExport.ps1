<#
.NOTES
    Owner/Responsible Information
    ---------------------------------------------------------------------------------------------
    T-SYSTEMS Iberia SAU
    A Deutsche Telecom Group Company
    CSS · Communication and Collaboration Services
        
    Code Creator:   fmb.fmb-tb-ib-lt2c-transformacio@t-systems.com 
    Script Name:    DRSupport_GPOExport
    Created:        20161021_1000
    Modified:       20160425_0952
    Version:        4.0

    BasedOnTemplateCode: 20160120_1630

    Additional Information
    --------------------------------------------------------------------------------------------
    Write here the complementary information, including comments and external links.
    
    How To Get This Help
    --------------------------------------------------------------------------------------------
    Get-Help .\ScriptName.ps1 -full

.SYNOPSIS
    Exportació de GPO

.DESCRIPTION            
    Exportació de GPO 
#> 

## Script
#Start-Transcript -path _transcript.out #comment if you don't need this functionality 
Clear-Host

## LoadingCurrentDomainValues
Import-Module ActiveDirectory
$FQDNDomainName = (Get-ADDomain).DNSRoot #sample 'mysample.contoso.com'
$DomainDN = (Get-ADDomain).DistinguishedName #sample 'dc:mysample;dc=contoso;dc=com'
$DomainShort = (Get-ADDomain).Name #sample 'contoso'
$Domain = (Get-WmiObject -Class Win32_Process | Where-Object {$_.ProcessName -eq 'explorer.exe'}).GetOwner() | Select-Object Domain
$User =  (Get-WmiObject -Class Win32_Process | Where-Object {$_.ProcessName -eq 'explorer.exe'}).GetOwner() | Select-Object User

## LoadingEnvironmentScriptValues
$TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss" #script starting time-stamp
$ScriptNameFullPath = ($MyInvocation.MyCommand.Definition).ToLower() #sample 's:\scriptfolder\myscript.ps1'
$ScriptNameExt  =  ($MyInvocation.MyCommand.Name).ToLower() #sample 'myscript.ps1'
$ScriptName = ($ScriptNameExt.substring(0,$ScriptNameExt.Length -4)).ToLower() #sample 'myscript'
$ScriptFullPath = ($ScriptNameFullPath.substring(0,$ScriptNameFullPath.Length - $ScriptNameExt.Length)).ToLower() #sample 's:\scriptfolder\'
$LogFile = $ScriptFullPath + "log\" + $ScriptName + "_" + $TimeStamp + ".log" #sample 's:\scriptfolder\log\myscript_YYYYMMDD_HHmmss.log'

## OtherValuesRegistration

## LogFileInit
If (-not (Test-Path log)) {New-Item log -ItemType Directory} 
(Get-Date -Format "yyyyMMdd_HHmmss") + " - Script Started - " + $ScriptName | Out-File -append $LogFile
"$Domain $User" | Out-File -append $LogFile
"·······" |  Out-File -append $LogFile





#Variables fixes
    $NomEquip = Get-Content env:computername
    $Equip= "_"+"$NomEquip"+"_"
	$RutaBKP = "\\cosentinogroup.net\dfs\DFS_COS\GPOExport\"
	$Data=Get-Date -format "yyyyMMdd"
	$Dataesborrar =(get-date).AddDays(-8).tostring("yyyyMMdd")
    $hora=Get-Date -format "HHmmss"
	$Fitxerdavui = echo $data$equip$hora
	$FitxerEsborrar = echo $dataesborrar$equip"*"
	$Log = "\\cosentinogroup.net\dfs\DFS_COS\GPOExport\GPOExport.log"


#Creació de l'eventlog i directori 
	# New-EventLog -LogName System -Source "LT2C_ADDS" -ErrorAction SilentlyContinue | Out-Null
	md \\cosentinogroup.net\dfs\DFS_COS\GPOExport\$data$equip$Hora  -ErrorAction SilentlyContinue

#Esborrem errors
	$error.clear()


#Backup de les GPOs
	backup-gpo -all -path $RutaBKP$data$equip$Hora -comment Cosentino_GPO_FullExport | select displayname, ID > $RutaBKP$data$equip$Hora\guia.txt

#Control d'errors
	if ($error[0] -eq $null) {
		echo "COS_ADDS $Equip $data $hora Completat correctament"| Out-File -filepath $log -Append 
		# Write-EventLog -logname System -Source "LT2C_ADDS" -EntryType Information -EventId 0 -Message "$NomEquip lt2c GPO Export successful" 
		del $RutaBKP$FitxerEsborrar -recurse -Force 

		} 
	else {
		echo "COS_ADDS $Equip $data $hora $Error[0]" | Out-File -filepath $log -Append 
		# Write-EventLog -logname System -Source "LT2C_ADDS" -EntryType Error -EventId 2 -Message "$NomEquip lt2c ADDS Export Error --- $error" 
	}


####### --------------  EndOfMainScript

## LogFileEndingData
"········" | Out-File -append $LogFile
(Get-Date -Format "yyyyMMdd_HHmmss") + " - Script Finnished" | Out-File -append $LogFile
"·············" | Out-File -append $LogFile

## EventLogScriptEntryRegistration
#New-EventLog -source LT2C_Scripting -logname System -ErrorAction SilentlyContinue  #creates LT2C_Scripting category in System log
#Write-EventLog -logname System -Source LT2C_Scripting -EntryType Information -EventId 0 -Message "T-Systems Iberia CSS.CCS.Scripting [$ScriptName] Completed" #writes an event related to script execution

## LogFileCallToReview
#Invoke-Item $LogFile

## EndingOfScript
#Stop-Transcript
Exit #for an alternate exit codes (https://support.microsoft.com/en-us/kb/304888)