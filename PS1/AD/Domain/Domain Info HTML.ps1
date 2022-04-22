$header = @"
<title>REPORT DOMAIN</title>
<style>
h1 {
    font-family: Arial, Helvetica, sans-serif;
    color: #e68a00;
    font-size: 28px;  
    
}
  
h2 {
    font-family: Arial, Helvetica, sans-serif;
    color: #000099;
    font-size: 16px;
}

h3 {
    font-family: Arial, Helvetica, sans-serif;
    color: #000099;
    font-size: 12px;
    margin-top: 20px;
}

div {
    margin: 50px;
}

       
table {
    font-size: 12px;
	border: 0px; 
	font-family: Arial, Helvetica, sans-serif;    
}

th {
    background: #395870;
    background: linear-gradient(#49708f, #293f50);
    color: #fff;
    font-size: 11px;
    text-transform: uppercase;
    padding: 10px 15px;
    vertical-align: middle;
}	

td {
    padding: 4px;
	margin: 0px;
	border: 0;
    text-align:center;
}

tbody tr:nth-child(even) {
    background: #f0f0f2;
}

</style>
"@

$Body = @"
<div><h1>Extracció dades Domini</h1>
"@

$Modul = Get-Module -ListAvailable ServerManager
Import-Module -ModuleInfo $Modul

$ADForest = Get-ADForest
$ADDomain = Get-ADDomain
$allDCs = $ADForest.Domains | %{ Get-ADDomainController -Filter * -Server $_ }

$ConfAD = "cn=configuration," + $ADDomain.DistinguishedName
$DHCPList = Get-ADObject -SearchBase $ConfAD -Filter "objectclass -eq 'dhcpclass' -AND Name -ne 'dhcproot'"

$Servers = Get-ADComputer -Filter 'operatingsystem -like "*server*"' -properties Name
$Other = ""

#######
$Domini =  $ADForest | ConvertTo-Html -Property Name -Fragment -as List -PreContent "<h2>Domini</h2>" 
$ForestMode = $ADForest | ConvertTo-Html -Property ForestMode -Fragment -as List -PreContent "<h2>Versió Domini</h2>" 
$DomainMode = $ADDomain | ConvertTo-Html -Property DomainMode -Fragment -as List 
$Schema = $ADForest | ConvertTo-Html -Property SchemaMaster, DomainNamingMaster -Fragment -as List -PreContent "<h2>FSMO Rols</h2>" 
$PDC = $ADDomain | ConvertTo-Html -Property PDCEmulator, RIDMaster, InfrastructureMaster -Fragment -as List 
$DomainControllers = $allDCs | ConvertTo-Html -Property Hostname, IPv4Address, OperatingSystem, IsGlobalCAtalog, IsReadOnly, Site, Enabled -as Table -PreContent "<h2>Domain Controllers</h2>"
$DHCPS = $DHCPList | ConvertTo-Html -Property Name -Fragment -as Table -PreContent "<h2>DHCPs</h2>"

$Report = ConvertTo-HTML -Head $header -Body "$Body $Domini $ForestMode $DomainMode $Schema $PDC $DomainControllers $DHCPS" -PostContent "<h3>Data Creació: $(Get-Date)</h3></div>"

#MODIFICAR RUTA ON DESAR
$Report | Out-File C:\Users\enric.ferrer\desktop\test.html










