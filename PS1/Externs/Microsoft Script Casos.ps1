############################################################################################################# ADFS troubleshooting - Data Collection# Supported versions: Windows Server 2012, Windows Server 2012 R2, Windows Server 2016 and Server 2019# Supported role: ADFS server, ADFS proxy server (2012) and Web Application Proxy (2012 R2 and 2016 and 2019)# Version:1.9b############################################################################################################param (    [Parameter(Mandatory=$false)]    [string] $Path,    [Parameter(Mandatory=$false)]    [bool]$TraceEnabled,    [Parameter(Mandatory=$false)]    [bool]$NetTraceEnabled,    [Parameter(Mandatory=$false)]    [bool]$PerfCounter)###########################################################################region Parameters[Version]$WinVer = (Get-WmiObject win32_operatingsystem).version
$IsProxy = ((Get-WindowsFeature -name ADFS-Proxy).Installed -or (Get-WindowsFeature -name Web-Application-Proxy).Installed)$isdomainjoined = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain# Event logs$ADFSDebugEvents = "Microsoft-Windows-CAPI2/Operational","AD FS Tracing/Debug","Device Registration Service Tracing/Debug"$WAPDebugEvents  = "Microsoft-Windows-CAPI2/Operational","AD FS Tracing/Debug","Microsoft-Windows-WebApplicationProxy/Session"$ADFSExportEvents = 'System','Application','Security','AD FS Tracing/Debug','AD FS/Admin','Microsoft-Windows-CAPI2/Operational','Device Registration Service Tracing/Debug','DRS/Admin'$WAPExportEvents  = 'System','Application','Security','AD FS Tracing/Debug','AD FS/Admin','Microsoft-Windows-CAPI2/Operational','Microsoft-Windows-WebApplicationProxy/Admin','Microsoft-Windows-WebApplicationProxy/Session'$DbgLvl = 5#Definition Netlogon Debug Logging$setDBFlag = 'DBFlag'
$setvaltype = [Microsoft.Win32.RegistryValueKind]::String
$setvalue = "0x2fffffff"
# Netlogon increase size to 100MB = 102400000Bytes = 0x61A8000)
$setNLMaxLogSize = 'MaximumLogFileSize'
$setvaltype2 = [Microsoft.Win32.RegistryValueKind]::DWord
$setvalue2 = 0x061A8000# Store the original values to revert the config after collection
$orgdbflag = (get-itemproperty -PATH "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters").$setDBFlag$orgNLMaxLogSize = (get-itemproperty -PATH "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters").$setNLMaxLogSize #ETW Trace providers$LogmanOn = 'logman.exe create trace "schannel" -ow -o .\schannel.etl -p {37D2C3CD-C5D4-4587-8531-4696C44244C8} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 2048 -ets',`'logman create trace "kerbntlm" -ow -o .\kerbntlm.etl -p {6B510852-3583-4E2D-AFFE-A67F9F223438} 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 2048 -ets',`'logman update trace "kerbntlm" -p {5BBB6C18-AA45-49B1-A15F-085F7ED0AA90} 0xffffffffffffffff 0xff -ets',`'logman create trace "dcloc" -ow -o .\dcloc.etl -p "Microsoft-Windows-DCLocator" 0xffffffffffffffff 0xff -nb 16 16 -bs 1024 -mode Circular -f bincirc -max 2048 -ets',`'logman update trace "dcloc" -p {6B510852-3583-4E2D-AFFE-A67F9F223438} 0xffffffffffffffff 0xff -ets',`'logman update trace "dcloc" -p {5BBB6C18-AA45-49B1-A15F-085F7ED0AA90} 0xffffffffffffffff 0xff -ets'#NetworkCapture$EnableNetworkTracer = 'netsh trace start scenario=internetServer capture=yes report=yes overwrite=yes maxsize=800 tracefile=.\%COMPUTERNAME%-HTTP-network.etl provider="{DD5EF90A-6398-47A4-AD34-4DCECDEF795F}" keywords=0xffffffffffffffff level=0xff provider="Microsoft-Windows-HttpService" keywords=0xffffffffffffffff level=0xff provider="Microsoft-Windows-HttpEvent" keywords=0xffffffffffffffff level=0xff provider="Microsoft-Windows-Http-SQM-Provider" keywords=0xffffffffffffffff level=0xff provider="{B3A7698A-0C45-44DA-B73D-E181C9B5C8E6}" keywords=0xffffffffffffffff level=0xff'$DisableNetworkTracer = 'netsh trace stop'#Performance Counter$CreatePerfCountProxy = 'Logman.exe create counter ADFSProxy -o ".\ADFSProxy-perf.blg" -f bincirc -max 1024 -v mmddhhmm -c "\AD FS Proxy\*" "\LogicalDisk(*)\*" "\Memory\*" "\PhysicalDisk(*)\*" "\Process(*)\*" "\Processor(*)\*" "\TCPv4\*" -si 0:00:05'$EnablePerfCountProxy = 'Logman.exe start ADFSProxy'

$DisablePerfCountProxy = 'Logman.exe stop ADFSProxy'
$RemovePerfCountProxy = 'Logman.exe delete ADFSProxy'

$CreatePerfCountADFS = 'Logman.exe create counter ADFSBackEnd -o ".\%COMPUTERNAME%-ADFSBackEnd-perf.blg" -f bincirc -max 1024 -v mmddhhmm -c "\AD FS\*" "\LogicalDisk(*)\*" "\Memory\*" "\PhysicalDisk(*)\*" "\Process(*)\*" "\Processor(*)\*" "\Netlogon(*)\*" "\TCPv4\*" "Netlogon(*)\*" -si 00:00:05'$EnablePerfCountADFS = 'Logman.exe start ADFSBackEnd'

$DisablePerfCountADFS = 'Logman.exe stop ADFSBackEnd'
$RemovePerfCountADFS = 'Logman.exe delete ADFSBackEnd'$LogmanOff = 'logman stop "schannel" -ets',`
'logman stop "kerbntlm" -ets',`
'logman stop "dcloc" -ets'$others = 'nltest /dsgetdc:%USERDNSDOMAIN% > %COMPUTERNAME%-nltest-dsgetdc-USERDNSDOMAIN-BEFORE.txt',`
'certutil -verifystore AdfsTrustedDevices > %COMPUTERNAME%-certutil-verifystore-AdfsTrustedDevices-BEFORE.txt',`
'certutil -v -store AdfsTrustedDevices > %COMPUTERNAME%-certutil-v-store-AdfsTrustedDevices-BEFORE.txt',`'ipconfig /flushdns > %COMPUTERNAME%-ipconfig-flushdns-BEFORE.txt'#Collection for Additional Files

$Filescollector = 'copy /y %windir%\debug\netlogon.*  ',`
'ipconfig /all > %COMPUTERNAME%-ipconfig-all-AFTER.txt',`
'netstat -nao > %COMPUTERNAME%-netstat-nao-AFTER.txt',`
'copy %WINDIR%\system32\drivers\etc\hosts %COMPUTERNAME%-hosts.txt',`
'netsh dnsclient show state > %COMPUTERNAME%-netsh-dnsclient-show-state-AFTER.txt',`
'set > %COMPUTERNAME%-environment-variables-AFTER.txt',`
'route print > %COMPUTERNAME%-route-print-AFTER.txt',`
'netsh advfirewall show global > %COMPUTERNAME%-netsh-int-advf-show-global.txt',`
'net start > %COMPUTERNAME%-services-running-AFTER.txt',`
'sc query  > %COMPUTERNAME%-services-config-AFTER.txt',`
'tasklist > %COMPUTERNAME%-tasklist-AFTER.txt',`
'if defined USERDNSDOMAIN (nslookup %USERDNSDOMAIN% > %COMPUTERNAME%-nslookup-USERDNSDOMAIN-AFTER.txt)',`
'nltest /dsgetdc:%USERDNSDOMAIN% > %COMPUTERNAME%-nltest-dsgetdc-USERDNSDOMAIN-AFTER.txt',`
'certutil -verifystore my > %COMPUTERNAME%-certutil-verifystore-my.txt',`
'certutil -verifystore ca > %COMPUTERNAME%-certutil-verifystore-ca.txt',`
'certutil -verifystore root > %COMPUTERNAME%-certutil-verifystore-root.txt',`
'certutil -verifystore AdfsTrustedDevices > %COMPUTERNAME%-certutil-verifystore-AdfsTrustedDevices-AFTER.txt',`
'certutil -v -store my > %COMPUTERNAME%-certutil-v-store-my.txt',`
'certutil -v -store ca > %COMPUTERNAME%-certutil-v-store-ca.txt',`
'certutil -v -store root > %COMPUTERNAME%-certutil-v-store-root.txt',`
'certutil -v -store AdfsTrustedDevices > %COMPUTERNAME%-certutil-v-store-AdfsTrustedDevices-AFTER.txt',`
'certutil –urlcache > %COMPUTERNAME%-cerutil-urlcache.txt',`
'certutil –v –store –enterprise ntauth > %COMPUTERNAME%-cerutil-v-store-enterprise-ntauth.txt',`
'netsh int ipv4 show dynamicport tcp > %COMPUTERNAME%-netsh-int-ipv4-show-dynamicport-tcp.txt',`
'netsh int ipv4 show dynamicport udp > %COMPUTERNAME%-netsh-int-ipv4-show-dynamicport-udp.txt',`
'netsh int ipv6 show dynamicport tcp > %COMPUTERNAME%-netsh-int-ipv6-show-dynamicport-tcp.txt',`
'netsh int ipv6 show dynamicport udp > %COMPUTERNAME%-netsh-int-ipv6-show-dynamicport-udp.txt',`
'netsh http show cacheparam > %COMPUTERNAME%-netsh-http-show-cacheparam.txt',`
'netsh http show cachestate > %COMPUTERNAME%-netsh-http-show-cachestate.txt',`
'netsh http show sslcert > %COMPUTERNAME%-netsh-http-show-sslcert.txt',`
'netsh http show iplisten > %COMPUTERNAME%-netsh-http-show-iplisten.txt',`
'netsh http show servicestate > %COMPUTERNAME%-netsh-http-show-servicestate.txt',`
'netsh http show timeout > %COMPUTERNAME%-netsh-http-show-timeout.txt',`
'netsh http show urlacl > %COMPUTERNAME%-netsh-http-show-urlacl.txt',`
'netsh winhttp show proxy > %COMPUTERNAME%-netsh-winhttp-proxy.txt',`
'wmic qfe list full /format:htable > %COMPUTERNAME%-WindowsPatches.htm',`
'GPResult /f /h %COMPUTERNAME%-GPReport.html',`
'Msinfo32 /nfo %COMPUTERNAME%-msinfo32-AFTER.nfo',`
'regedit /e %COMPUTERNAME%-reg-RPC-ports-and-general-config.txt HKEY_LOCAL_MACHINE\Software\Microsoft\Rpc',`
'regedit /e %COMPUTERNAME%-reg-NTDS-port-and-other-params.txt HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NTDS\parameters',`
'regedit /e %COMPUTERNAME%-reg-NETLOGON-port-and-other-params.txt HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Netlogon\parameters',`
'regedit /e %COMPUTERNAME%-reg-schannel.txt HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL',`'regedit /e %COMPUTERNAME%-reg-Cryptography_registry.txt HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Cryptography',`
'regedit /e %COMPUTERNAME%-reg-schannel_NET_strong_crypto.txt HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework',`
'regedit /e %COMPUTERNAME%-reg-schannel_NET_WOW_strong_crypto.txt HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework',`
'regedit /e %COMPUTERNAME%-reg-ciphers_policy_registry.txt HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL'#endregion###########################################################################region UIFunction RunDialog {
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '800,600'
$Form.text                       = "ADFS Trace Collector"
$Form.TopMost                    = $false
$Form.StartPosition              = 'CenterScreen'
$Form.MaximizeBox                = $false
$Form.MinimizeBox                = $false
$Form.FormBorderStyle            = [System.Windows.Forms.FormBorderStyle]::Fixed3D
# Text field
$Description                     = New-Object system.Windows.Forms.RichTextBox
$Description.multiline           = $true
$Description.text                = "Before running this script consider running the ADFS Diagnostic Analyzer to detect possible existing configuration problems
You can obtain the ADFS Diagnostic Analyzer from the following webpage: https://adfshelp.microsoft.com/DiagnosticsAnalyzer/Analyze

This ADFS Tracing script is intended to collect various details about the ADFS configuration and related Windows Settings.

It also provides the capability to collect various debug logs at runtime for issues that needs to be actively reproduced or are otherwise not detectable
via the ADFS Diagnostic Analyzer and the resulting data can be provided to a Microsoft support technician for analysis.

When running a Debug/Runtime Trace you can choose to add Network Traces and/or Performance Counter to the collection if it is required to troubleshoot
a particular issue.

The script will prepare itself to start capturing data and will prompt the Administrator once the data collection script is ready. 
When you have the script in this prompt on all the servers, just hit any key to start collecting data in all of them.
It will then display another message to inform you that it's collecting data and will wait for another key to be pressed to stop the capture.

Note: The script will capture multiple traces in circular buffers. It will use a temporary folder under the path you provide (Example: C:\tracing\temporary).
The temporary folder will be compressed and .zip file left in the path file you selected. 
In worst case it will require 10-12 GB depending on the workload and the time we keep it running, but usually it's below 4GB.
Consider capturing the data in a period of time with low workload in your ADFS environment.
"
$Description.width               = 780
$Description.height              = 360
$Description.location            = New-Object System.Drawing.Point(15,0)
$Description.Font                = 'Arial,10'
$Description.ScrollBars          = 'Vertical'
$Description.ReadOnly            = $true
$Description.DetectUrls          = $true

#Configuration only Button
$cfgonly                         = New-Object system.Windows.Forms.CheckBox
$cfgonly.text                    = "Configuration only"
$cfgonly.AutoSize                = $false
$cfgonly.width                   = 220
$cfgonly.height                  = 20
$cfgonly.location                = New-Object System.Drawing.Point(15,380)
$cfgonly.Font                    = 'Arial,10'

#Checkbox for Debug Tracing
$TracingMode                     = New-Object system.Windows.Forms.CheckBox
$TracingMode.text                = "Runtime Tracing"
$TracingMode.AutoSize            = $false
$TracingMode.width               = 220
$TracingMode.height              = 20
$TracingMode.location            = New-Object System.Drawing.Point(15,415)
$TracingMode.Font                = 'Arial,10'
#Checkbox to invlude Network Tracing
$NetTrace                        = New-Object system.Windows.Forms.CheckBox
$NetTrace.text                   = "include Network Traces"
$NetTrace.AutoSize               = $false
$NetTrace.Enabled                = $false
$NetTrace.width                  = 220
$NetTrace.height                 = 20
$NetTrace.location               = New-Object System.Drawing.Point(15,450)
$NetTrace.Font                   = 'Arial,10'

#include Performance Counters
$perfc                           = New-Object system.Windows.Forms.CheckBox
$perfc.text                      = "include Performance Counter"
$perfc.AutoSize                  = $false
$perfc.Enabled                   = $false
$perfc.width                     = 260
$perfc.height                    = 20
$perfc.location                  = New-Object System.Drawing.Point(340,450)
$perfc.Font                      = 'Arial,10'

#Text Field for the Export Path to store the results
$label                           = New-Object System.Windows.Forms.Label
$label.Location                  = New-Object System.Drawing.Point(15,480)
$label.Size                      = New-Object System.Drawing.Size(518,20)
$label.Text                      = 'Type a path to the Destination Folder or Click "Browse..." to select the Folder'
$label.Font                      = 'Arial,8'

$TargetFolder                    = New-Object system.Windows.Forms.TextBox
$TargetFolder.text               = ""
$TargetFolder.width              = 470
$TargetFolder.height             = 80
$TargetFolder.location           = New-Object System.Drawing.Point(15,501)
$TargetFolder.Font               = 'Arial,13'

#Browser Folder button
$SelFolder                       = New-Object system.Windows.Forms.Button
$SelFolder.text                  = "Browse..."
$SelFolder.width                 = 90
$SelFolder.height                = 29
$SelFolder.location              = New-Object System.Drawing.Point(490,500)
$SelFolder.Font                  = 'Arial,10'

$Okbtn                           = New-Object system.Windows.Forms.Button
$Okbtn.text                      = "OK"
$Okbtn.width                     = 70
$Okbtn.height                    = 30
$Okbtn.location                  = New-Object System.Drawing.Point(600,540)
$Okbtn.Font                      = 'Arial,10'
$Okbtn.DialogResult              = [System.Windows.Forms.DialogResult]::OK
$Okbtn.Enabled                   = $false

$cnlbtn                          = New-Object system.Windows.Forms.Button
$cnlbtn.text                     = "Cancel"
$cnlbtn.width                    = 70
$cnlbtn.height                   = 30
$cnlbtn.location                 = New-Object System.Drawing.Point(700,540)
$cnlbtn.Font                     = 'Arial,10'
$cnlbtn.DialogResult              = [System.Windows.Forms.DialogResult]::Cancel


$Form.controls.AddRange(@($Description,$TracingMode,$NetTrace,$TargetFolder,$SelFolder,$Okbtn,$cnlbtn,$cfgonly,$perfc,$label))

# Config-control
#If Config is selected we want a static dump and not collect any runtime activity; prevent selecting TraceMode and/or Networktrace and/or PerfTracing
$cfgonly.Add_CheckStateChanged({ if ($cfgonly.checked)
                                {$TracingMode.Enabled = $false; $NetTrace.Enabled = $false; $perfc.Enabled = $false}
                                else
                                {$TracingMode.Enabled = $true; $NetTrace.Enabled = $false}
                                                              
                              })
#If TracingMode is selected we want a config dump + Debug Tracing
#optionally we also want a network trace to check for Kerberos,LDAP or generall connectivity Issues
#dump and not collect any runtime activity; prevent selecting TraceMode and/or Networktrace
$TracingMode.Add_CheckStateChanged({ if ($TracingMode.checked)
                                {$cfgonly.Enabled = $false; $NetTrace.Enabled = $true;$NetTrace.Checked = $true; $perfc.Enabled = $true}
                                else
                                {$cfgonly.Enabled = $true; $NetTrace.Checked = $false; $NetTrace.Enabled = $false;$perfc.Checked = $false; $perfc.Enabled = $false }
                              })

#For future Versions we may add addional dependencies to the Network Trace.
#$NetTrace.Add_CheckedChanged({ })

#Click on Link Event Handler
$Description.add_LinkClicked({
    Start-Process -FilePath $_.LinkText
})

#Browse Button will open a FolderBrowser to navigate/select and update the Text Field with the selected path
$SelFolder.Add_Click({ 
                                #Add-Type -AssemblyName System.Windows.Forms
                                $FolderDialog = New-Object windows.forms.FolderBrowserDialog   
                                $FolderDialog.RootFolder = "Desktop"
                                $FolderDialog.ShowDialog()
                                $TargetFolder.text  = $FolderDialog.SelectedPath
 })


#Else type the Path to an existing folder and once the text changed enable the OK Button
#We check that at least one Scenario Trace or Config Only has been selected
$TargetFolder.Add_TextChanged({ 
                                ($Okbtn.Enabled = $true) 
                             })


$FormsCOmpleted = $Form.ShowDialog()

if ($FormsCOmpleted -eq [System.Windows.Forms.DialogResult]::OK)
    {
        New-Object psobject -Property @{
            Path    = $TargetFolder.text
            TraceEnabled = $TracingMode.Checked
            NetTraceEnabled = $NetTrace.Checked
            ConfigOnly = $cfgonly.Checked
            PerfCounter =$perfc.Checked
        }
    }
elseif($FormsCOmpleted -eq [System.Windows.Forms.DialogResult]::Cancel)
    {
    Write-host "Script was aborted by Cancel"
    exit
    }

}###########################################################################region FunctionsFunction EnableDebugEvents ($events){    if($TraceEnabled)    {        	ForEach ($evt in $events)        	{	        	$TraceLog = New-Object System.Diagnostics.Eventing.Reader.EventlogConfiguration $evt        		$TraceLog.IsEnabled = $false        		$TraceLog.SaveChanges()	        	if ($TraceLog.LogName -like "*Tracing/Debug*")	        	{       	        		$TraceLog.ProviderLevel = 5        			$TraceLog.IsEnabled = $true	        		$TraceLog.SaveChanges()        		}         		elseif($TraceLog.IsEnabled -eq $false) 	        	{        			$tracelog.MaximumSizeInBytes = '40000000'	        		$TraceLog.IsEnabled = $true	        		$TraceLog.SaveChanges()	           	} 	        }    }    else    {    Write-Host "Debug Event Logging skipped due to selected scenario"    }}Function LogManStart{    if($TraceEnabled)    {	        ForEach ($ets in $LogmanOn)	        {		    Push-Location $TraceDir		    cmd /c $ets		    Pop-Location	        }    }     else    {     Write-Host "ETW Tracing skipped due to selected scenario"    }}

Function EnableNetlogonDebug
{
    if($TraceEnabled)    {
        $key = (get-item -PATH "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon")
        $subkey = $key.OpenSubKey("Parameters",$true)
        Write-host "Enabling Netlogon Debug Logging"

        $subkey.SetValue($setDBFlag,$setvalue,$setvaltype)

        Write-host "Increasing Netlogon Debug Size to 100 MB"
        $subkey.SetValue($setNLMaxLogSize,$setvalue2,$setvaltype2)

        #cleanup and close the write  handle
        $key.Close()
    }
    else
    {
    Write-Host "Netlogon Logging skipped due to scenario"
    }
}Function AllOtherLogs{	ForEach ($o in $others) 	{		Push-Location $TraceDir		cmd.exe /c $o		Pop-Location	}}Function LogManStop
{
    if($TraceEnabled)    {
        ForEach ($log in $LogmanOff)         {	    	Push-Location $TraceDir	    	cmd.exe /c $log	    	Pop-Location        }
    }
    else
    {
    Write-host "ETW Tracing was not enabled"
    }
}

Function DisableNetlogonDebug
{
    if($TraceEnabled)    {
        $key = (get-item -PATH "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon")
        $subkey = $key.OpenSubKey("Parameters",$true)

        # Configure Keys based on initial configuration; if the keys did not exist we are also removing the keys again. else we set the old value
        if ([string]::IsNullOrEmpty($orgdbflag))
	    { 
        $subkey.deleteValue($setDBFlag)
	    }
        else 
	    {
        $subkey.SetValue($setDBFlag,$orgdbflag,$setvaltype)
	    }

        if ([string]::IsNullOrEmpty($orgNLMaxLogSize))
	    { 
        $subkey.deleteValue($setNLMaxLogSize)
	    }
        else 
	    {
        $subkey.SetValue($setNLMaxLogSize,$orgNLMaxLogSize,$setvaltype2) 
	    }

        $key.Close()
    }
    else
    {
    Write-host "Net Logging logging was not enabled"
    }
}
Function DisableDebugEvents ($events){    if($TraceEnabled)    {        ForEach ($evt in $events)        {		    $TraceLog = New-Object System.Diagnostics.Eventing.Reader.EventlogConfiguration $evt		    if ($TraceLog.IsEnabled -eq $true)             {			    $TraceLog.IsEnabled = $false			    $TraceLog.SaveChanges()            }         }

    }
    else
    {
    Write-host "Debug Tracing Evetnlogs where not enabled"
    }
}

Function ExportEventLogs ($events)
{
    ForEach ($evts in $events)     {		Push-Location $TraceDir		# Replace slashes in the event filename before building the export paths		$evtx = [regex]::Replace($evts,"/","-")		$evttarget = $TraceDir +"\"+ $evtx+".evtx"
		$evttarget
		$EventSession = New-Object System.Diagnostics.Eventing.Reader.EventLogSession		$EventSession.ExportLogAndMessages($evts,'Logname','*',$evttarget)		Pop-Location    }
}

Function GatherTheRest
{
    ForEach ($logfile in $Filescollector)     {		Push-Location $TraceDir		cmd.exe /c $logfile 		Pop-Location    }
}


Function EnablePerfCounter
{
    if ($TraceEnabled -and $PerfCounter)
        { 
            if ($IsProxy)
            {
            Write-host "Enabling PerfCounter"
            Push-Location $TraceDir            cmd /c $CreatePerfCountProxy		    cmd /c $EnablePerfCountProxy		    Pop-Location
            
            }
            else
            {
            Push-Location $TraceDir            Write-host "Configuring PerfCounter"            cmd /c $CreatePerfCountADFS		    cmd /c $EnablePerfCountADFS            Pop-Location
            }
    }
    else
    {
    Write-Host "Performance Monitoring is not sampled due to selected scenario"
    }
}

Function DisablePerfCounter
{
    if ($TraceEnabled -and $PerfCounter)
        { 
            if ($IsProxy)
            {
		    cmd /c $DisablePerfCountProxy            #we need to remove the counter created during enablement            cmd /c $RemovePerfCountProxy            }
            else
            {
		    cmd /c $DisablePerfCountADFS            #we need to remove the counter created during enablement            cmd /c $RemovePerfCountADFS            }
    }
    else
    {
    Write-Host "Performance Monitoring was not sampled due to selected scenario"
    }
}


Function EnableNetworkTrace

{
    if ($TraceEnabled -and $NetTraceEnabled)
    { 
            Write-host "Starting Network Trace"
            Push-Location $TraceDir		    cmd /c $EnableNetworkTracer		    Pop-Location
    }
    else
    {
    #Write-Host "Network Tracing is not sampled due to selected scenario"
    }
}

Function DisableNetworkTrace

{
    if ($TraceEnabled -and $NetTraceEnabled)
    { 
        Write-host "Stopping Network Trace. It may take a moment for the data to be flushed to disk"
        cmd /c $DisableNetworkTracer
    }
    else
    {
    #Write-host "Configuring PerfCounter"
    }
}



Function GetADFSConfig
{

    Push-Location $TraceDir
    if ($IsProxy) # Is ADFS proxy or Web Application Proxy (WAP)    {
	    if ($WinVer -eq [Version]"6.2.9200") # ADFS proxy 2012
	    {
		    Get-AdfsProxyProperties | format-list * | Out-file "Get-AdfsProxyProperties.txt"
	    }	    else # ADFS 2012 R2 or ADFS 2016 or 2019	    {		    Get-WebApplicationProxyApplication | format-list * | Out-file "Get-WebApplicationProxyApplication.txt"		    Get-WebApplicationProxyAvailableADFSRelyingParty | format-list * | Out-file "Get-WebApplicationProxyAvailableADFSRelyingParty.txt"		    Get-WebApplicationProxyConfiguration | format-list * | Out-file "Get-WebApplicationProxyConfiguration.txt"		    Get-WebApplicationProxyHealth | format-list * | Out-file "Get-WebApplicationProxyHealth.txt"		    Get-WebApplicationProxySslCertificate | format-list * | Out-file "Get-WebApplicationProxySslCertificate.txt"		    $proxcfg = 'copy %WINDIR%\ADFS\Config\Microsoft.IdentityServer.ProxyService.exe.config %COMPUTERNAME%-Microsoft.IdentityServer.ProxyService.exe.config'            cmd.exe /c $proxcfg	    }
    }
    else # Is ADFS server
 {
	    # Common ADFS commands to all versions
	    Get-AdfsAttributeStore | format-list * | Out-file "Get-AdfsAttributeStore.txt"
	    Get-AdfsCertificate | format-list * | Out-file "Get-AdfsCertificate.txt"
	    Get-AdfsClaimDescription | format-list * | Out-file "Get-AdfsClaimDescription.txt"
	    Get-AdfsClaimsProviderTrust | format-list * | Out-file "Get-AdfsClaimsProviderTrust.txt"
	    Get-AdfsEndpoint | format-list * | Out-file "Get-AdfsEndpoint.txt"
	    Get-AdfsProperties | format-list * | Out-file "Get-AdfsProperties.txt"
	    Get-AdfsRelyingPartyTrust | format-list * | Out-file "Get-AdfsRelyingPartyTrust.txt"
	    Get-AdfsSyncProperties | format-list * | Out-file "Get-AdfsSyncProperties.txt"
	    Get-AdfsSslCertificate | format-list * | Out-file "Get-AdfsSslCertificate.txt"
	

	if ($WinVer -ge [Version]"10.0.14393.0") # ADFS commands specific to ADFS 2016 and common in 2019
	    {
		Get-AdfsAccessControlPolicy | format-list * | Out-file "Get-AdfsAccessControlPolicy.txt"
		Get-AdfsApplicationGroup | format-list * | Out-file "Get-AdfsApplicationGroup.txt"
		Get-AdfsApplicationPermission | format-list * | Out-file "Get-AdfsApplicationPermission.txt"
		Get-AdfsAzureMfaConfigured | format-list * | Out-file "Get-AdfsAzureMfaConfigured.txt"
		Get-AdfsCertificateAuthority | format-list * | Out-file "Get-AdfsCertificateAuthority.txt"
		Get-AdfsClaimsProviderTrustsGroup | format-list * | Out-file "Get-AdfsClaimsProviderTrustsGroup.txt"
		Get-AdfsFarmInformation | format-list * | Out-file "Get-AdfsFarmInformation.txt"
		Get-AdfsLocalClaimsProviderTrust | format-list * | Out-file "Get-AdfsLocalClaimsProviderTrust.txt"
		Get-AdfsNativeClientApplication | format-list * | Out-file "Get-AdfsNativeClientApplication.txt"
		Get-AdfsRegistrationHosts | format-list * | Out-file "Get-AdfsRegistrationHosts.txt"
		Get-AdfsRelyingPartyTrustsGroup | format-list * | Out-file "Get-AdfsRelyingPartyTrustsGroup.txt"
		Get-AdfsRelyingPartyWebTheme | format-list * | Out-file "Get-AdfsRelyingPartyWebTheme.txt"
		Get-AdfsScopeDescription | format-list * | Out-file "Get-AdfsScopeDescription.txt"
		Get-AdfsServerApplication | format-list * | Out-file "Get-AdfsServerApplication.txt"
		Get-AdfsTrustedFederationPartner | format-list * | Out-file "Get-AdfsTrustedFederationPartner.txt"
		Get-AdfsWebApiApplication | format-list * | Out-file "Get-AdfsWebApiApplication.txt"
		Get-AdfsAdditionalAuthenticationRule | format-list * | Out-file "Get-AdfsAdditionalAuthenticationRule.txt"
		Get-AdfsAuthenticationProvider | format-list * | Out-file "Get-AdfsAuthenticationProvider.txt"
		Get-AdfsAuthenticationProviderWebContent | format-list * | Out-file "Get-AdfsAuthenticationProviderWebContent.txt"
		Get-AdfsClient | format-list * | Out-file "Get-AdfsClient.txt"
		Get-AdfsGlobalAuthenticationPolicy | format-list * | Out-file "Get-AdfsGlobalAuthenticationPolicy.txt"
		Get-AdfsGlobalWebContent | format-list * | Out-file "Get-AdfsGlobalWebContent.txt"
		Get-AdfsNonClaimsAwareRelyingPartyTrust | format-list * | Out-file "Get-AdfsNonClaimsAwareRelyingPartyTrust.txt"
		Get-AdfsRelyingPartyWebContent | format-list * | Out-file "Get-AdfsRelyingPartyWebContent.txt"
		Get-AdfsSslCertificate | format-list * | Out-file "Get-AdfsSslCertificate.txt"
		Get-AdfsWebApplicationProxyRelyingPartyTrust | format-list * | Out-file "Get-AdfsWebApplicationProxyRelyingPartyTrust.txt"
		Get-AdfsWebConfig | format-list * | Out-file "Get-AdfsWebConfig.txt"
		Get-AdfsWebTheme | format-list * | Out-file "Get-AdfsWebTheme.txt"
		$svccfg = 'copy %WINDIR%\ADFS\Microsoft.IdentityServer.ServiceHost.Exe.Config %COMPUTERNAME%-Microsoft.IdentityServer.ServiceHost.Exe.Config'
        cmd.exe /c $svccfg

        ##comming soon: WHFB Cert Trust Informations


        if ($WinVer -ge [Version]"10.0.17763") #ADFS command specific to ADFS 2019+
        {
        #Get-AdfsDebugLogConsumersConfiguration
		Get-AdfsDirectoryProperties | format-list * | Out-file "Get-AdfsDirectoryProperties.txt"
        }
            
		}
	    if ($WinVer -eq [Version]"6.3.9600") # ADFS commands specific to ADFS 2012 R2
	    {	
         Get-AdfsAdditionalAuthenticationRule | format-list * | Out-file "Get-AdfsAdditionalAuthenticationRule.txt"
		 Get-AdfsAuthenticationProvider | format-list * | Out-file "Get-AdfsAuthenticationProvider.txt"
		 Get-AdfsAuthenticationProviderWebContent | format-list * | Out-file "Get-AdfsAuthenticationProviderWebContent.txt"
		 Get-AdfsClient | format-list * | Out-file "Get-AdfsClient.txt"
		 Get-AdfsGlobalAuthenticationPolicy | format-list * | Out-file "Get-AdfsGlobalAuthenticationPolicy.txt"
		 Get-AdfsGlobalWebContent | format-list * | Out-file "Get-AdfsGlobalWebContent.txt"
		 Get-AdfsNonClaimsAwareRelyingPartyTrust | format-list * | Out-file "Get-AdfsNonClaimsAwareRelyingPartyTrust.txt"
		 Get-AdfsRelyingPartyWebContent | format-list * | Out-file "Get-AdfsRelyingPartyWebContent.txt"
		 Get-AdfsWebApplicationProxyRelyingPartyTrust | format-list * | Out-file "Get-AdfsWebApplicationProxyRelyingPartyTrust.txt"
		 Get-AdfsWebConfig | format-list * | Out-file "Get-AdfsWebConfig.txt"
		 Get-AdfsWebTheme | format-list * | Out-file "Get-AdfsWebTheme.txt"
		 $svccfg = 'copy %WINDIR%\ADFS\Microsoft.IdentityServer.ServiceHost.Exe.Config %COMPUTERNAME%-Microsoft.IdentityServer.ServiceHost.Exe.Config'
         cmd.exe /c $svccfg
	    }
	    elseif ($WinVer -eq [Version]"6.2.9200")
	    {
		    # No specific cmdlets for this version
	    }
    }
    Pop-Location
}Function EndOfCollection{    $date = get-date -Format yyyy-dd-MM_hh-mm    $computername = (Get-Childitem env:computername).value    $zip = $computername + "_ADFS_traces_"+$date    $datafile = "$(Join-Path -Path $path -ChildPath $zip).zip"    Write-host "Creating Archive File"    Add-Type -Assembly "System.IO.Compression.FileSystem" ;    [System.IO.Compression.ZipFile]::CreateFromDirectory($TraceDir, $datafile)

    Write-host "Archive File created in $datafile"

    # Cleanup the Temporary Folder (if error retain the temp files)
    if(Test-Path -Path $Path)
    {
		Write-host "Removing Temporary Files"
		Remove-Item -Path $TraceDir -Force -Recurse | Out-Null
    }
    else    {		Write-host "The Archive could not be created. Keeping Temporary Folder $TraceDir"		New-Item -ItemType directory -Path $Path -Force | Out-Null    }}Function GetDRSConfig{    if ((-Not $IsProxy) -And ($WinVer -gt [Version]"6.2.9200")) 	{		Push-Location $TraceDir		Get-AdfsDeviceRegistrationUpnSuffix | format-list * | Out-file "Get-AdfsDeviceRegistrationUpnSuffix.txt"		Try { Get-AdfsDeviceRegistration | format-list * | Out-file "Get-AdfsDeviceRegistration.txt" }  Catch { $_.Exception.Message | Out-file "Get-AdfsDeviceRegistration.txt" }		Try		{			$rootdse = New-Object System.DirectoryServices.DirectoryEntry("LDAP://RootDSE")			$dirEntry = "LDAP://" +$rootdse.dnshostname+"/CN=DeviceRegistrationService,CN=Device Registration Services,CN=Device Registration Configuration,CN=Services," +$rootdse.configurationNamingContext			$searcher = new-object System.DirectoryServices.DirectorySearcher			$searcher.SearchRoot = $dirEntry			$searcher.SearchScope = "Subtree"			$DScloudissuerpubliccert = new-object System.Security.Cryptography.X509Certificates.X509Certificate2			$DScloudissuerpubliccert.Import(($searcher.FindAll()).GetDirectoryEntry().Properties.'msds-cloudissuerpubliccertificates'.Value)			$DSissuerpubliccert = new-object System.Security.Cryptography.X509Certificates.X509Certificate2			$DSissuerpubliccert.Import(($searcher.FindAll()).GetDirectoryEntry().Properties.'msDS-IssuerPublicCertificates'.Value)			"==========================CloudDRSIssuerCertificatePublicKey======================================" | Out-File Get-AdfsDeviceRegistration.txt -Append			$DScloudissuerpubliccert |fl * | Out-File Get-AdfsDeviceRegistration.txt -Append			"=============================DRSIssuerCertificatePublicKey========================================" | Out-File Get-AdfsDeviceRegistration.txt -Append			$DSissuerpubliccert |fl * | Out-File Get-AdfsDeviceRegistration.txt -Append		}		catch		{			"The function DRSConfig ran into the following Error when querying the AD DRS Object: " + ($_) | Out-File DiagnosticsDebug.txt -Append		}		pop-location	}}#endregion###########################################################################region Execution##If no path was specified when running the commandlet go for GUI (need to be adopted for Server Core)if ([string]::IsNullOrEmpty($Path)){$RunProp = RunDialog
$Path = $RunProp.Path.ToString()$TraceEnabled = $RunProp.TraceEnabled$NetTraceEnabled = $RunProp.NetTraceEnabled$ConfigOnly = $RunProp.ConfigOnly$PerfCounter = $RunProp.PerfCounter}elseif (![string]::IsNullOrEmpty($Path)){    if ($TraceEnabled -eq $false)    {        Write-host "Please Specify what data to capture"        $Mode = Read-Host 'For "Configuration Only" press "C" . For a "Debug Tracing" press "T"'        Switch ($Mode) 
                 { 
                    C {Write-host "You selected Configuration Only, skipping Debug logging"; $TraceEnabled=$false; $ConfigOnly=$true} 
                    T {Write-Host "You selected Tracing Mode, enabling additional logging"; $TraceEnabled=$true; ; $ConfigOnly=$false} 
                    Default {Write-Host "You did not selected an operationsmode. We will only collect the Configuration"; $TraceEnabled=$false; $ConfigOnly=$true} 
                 }     }    else    {        $ConfigOnly=$false    }    If (($TraceEnabled -and ($NetTraceEnabled -eq $false))  )    {            $NMode = Read-Host 'Collect a Network Trace (Y/N). If you do not provide a value network tracing is enabled by default'            Switch ($NMode) 
               { 
                 Y {Write-host "Enabling Network Tracing"; $NetTraceEnabled=$true; $ConfigOnly=$false} 
                 N {Write-Host "Skipping Network Tracing"; $NetTraceEnabled=$false; $ConfigOnly=$false} 
                 Default {Write-Host "You provided an incorrect or no value. Enabling Network Tracing"; $NetTraceEnabled=$true; $ConfigOnly=$false} 
               }     }    if (($TraceEnabled -and ($PerfCounter -eq $false)))    {            $PMode = Read-Host 'Collect Performance Counters (Y/N). You you do not provide a value network tracing is enabled by default'            Switch ($PMode) 
              { 
                   Y {Write-host "Collecting Performance Counter"; $PerfCounter=$true; $ConfigOnly=$false} 
                   N {Write-Host "Skipping Performance Counters"; $PerfCounter=$false; $ConfigOnly=$false} 
                   Default {Write-Host "You provided an incorrect or no value. Skipping Performance Counters"; $PerfCounter=$false; $ConfigOnly=$false} 
              }    }}if(Test-Path -Path $Path){     Write-host "Your folder: $Path already exists. Starting Data Collection..."}else{Write-host "Your Logfolder: $Path does not exist. Creating Folder"New-Item -ItemType directory -Path $Path -Force | Out-Null}$TraceDir = $Path +"\temporary"# Save execution output to fileWrite-host "Creating Temporary Folder in $path"New-Item -ItemType directory -Path $TraceDir -Force | Out-NullStart-Transcript -Path "$TraceDir\output.txt" -Append -IncludeInvocationHeaderWrite-Host "Debug logs will be saved in: " $PathWrite-Host "Options selected:  TracingEnabled:"$TraceEnabled "NetworkTrace:" $NetTraceEnabled " ConfigOnly:" $ConfigOnly " PerfCounter:" $PerfCounterWrite-Progress -Activity "Preparation" -Status 'Setup Data Directory' -percentcomplete 5 # if ($TraceEnabled){Write-Host " Data Collection is ready to start`n Prepare other computers to start collecting data.`n When ready, press any key to start the collection..." -ForegroundColor Green$silencer = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")}Write-Progress -Activity "Enable Logging" -Status 'Eventlogs' -percentcomplete 7 Write-host "Configuring Event Logging"if ($IsProxy) 	{ EnableDebugEvents $WAPDebugEvents  }else 			{ EnableDebugEvents $ADFSDebugEvents }Write-Progress -Activity "Enable Logging" -Status 'Additional ETL Logging' -percentcomplete 10LogManStartEnableNetworkTraceEnablePerfCounterWrite-Progress -Activity "Enable Logging" -Status 'Netlogon Debug Logging' -percentcomplete 12EnableNetlogonDebugWrite-Progress -Activity "Gathering Configuration Data" -Status 'Gathering Logfiles' -percentcomplete 15AllOtherLogs


Write-Progress -Activity "Gathering Configuration Data" -Status 'Getting ADFS Configuration' -percentcomplete 40
GetADFSConfigGetDRSConfig

if($TraceEnabled)
{
Write-Progress -Activity "Ready for Repro" -Status 'Waiting for Repro' -percentcomplete 50
Write-Host " Data Collection started`n Proceed reproducing the problem.`n Press any key to stop the collection..." -ForegroundColor Green$silencer = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")}


Write-Progress -Activity "Collecting" -Status 'Stop Event logging' -percentcomplete 55
if ($IsProxy) 	{ DisableDebugEvents $WAPDebugEvents  }else 			{ DisableDebugEvents $ADFSDebugEvents }Write-Progress -Activity "Collecting" -Status 'Stop Netlogon logging' -percentcomplete 65Write-host "Disabling Netlogon Debug Logging"DisableNetlogonDebugGatherTheRestWrite-Progress -Activity "Collecting" -Status 'Stop additional logs' -percentcomplete 70LogManStopDisableNetworkTraceDisablePerfCounterWrite-Progress -Activity "Collecting" -Status 'Exporting Eventlogs' -percentcomplete 85if ($IsProxy) 	{ ExportEventLogs $WAPExportEvents  }else 			{ ExportEventLogs $ADFSExportEvents }Stop-TranscriptWrite-Progress -Activity "Saving" -Status 'Compressing Files - This may take some moments to complete' -percentcomplete 95Write-host "Almost done. We are compressing all Files. Please wait"EndOfCollection#endregion