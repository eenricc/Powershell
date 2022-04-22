#################################################################################################################
# 
# Version 1.4 February 2016
# Robert Pearman (WSSMB MVP)
# TitleRequired.com
# Script to Automated Email Reminders when Users Passwords due to Expire.
#
# Requires: Windows PowerShell Module for Active Directory
#
# For assistance and ideas, visit the TechNet Gallery Q&A Page. http://gallery.technet.microsoft.com/Password-Expiry-Email-177c3e27/view/Discussions#content
# Or Checkout my Youtube Channel - https://www.youtube.com/user/robtitlerequired
#
##################################################################################################################
# Please Configure the following variables....
$smtpServer="172.29.3.13"
$expireindays = 20
$from = "COSENTINO PASSWORD <helpdesk@cosentino.com>"
$logging = "Enabled" # Set to Disabled to Disable Logging
$logFile = "C:\passlog\mylog.csv" # ie. c:\mylog.csv
$testing = "Disabled" # Set to Disabled to Email Users
$testRecipient = "helpdesk@cosentino.com"
#
###################################################################################################################

# Check Logging Settings
if (($logging) -eq "Enabled")
{
    # Test Log File Path
    $logfilePath = (Test-Path $logFile)
    if (($logFilePath) -ne "True")
    {
        # Create CSV File and Headers
        New-Item $logfile -ItemType File
        Add-Content $logfile "Date,Name,EmailAddress,DaystoExpire,ExpiresOn,Notified"
    }
} # End Logging Check

# System Settings
$textEncoding = [System.Text.Encoding]::UTF8
$date = Get-Date -format ddMMyyyy
# End System Settings

# Get Users From AD who are Enabled, Passwords Expire and are Not Currently Expired
Import-Module ActiveDirectory
$users = get-aduser -filter * -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress |where {$_.Enabled -eq "True"} | where { $_.PasswordNeverExpires -eq $false } | where { $_.passwordexpired -eq $false }
$DefaultmaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

# Process Each User for Password Expiry
foreach ($user in $users)
{
    $Name = $user.Name
    $emailaddress = $user.emailaddress
    $passwordSetDate = $user.PasswordLastSet
    $PasswordPol = (Get-AduserResultantPasswordPolicy $user)
    $sent = "" # Reset Sent Flag
    # Check for Fine Grained Password
    if (($PasswordPol) -ne $null)
    {
        $maxPasswordAge = ($PasswordPol).MaxPasswordAge
    }
    else
    {
        # No FGP set to Domain Default
        $maxPasswordAge = $DefaultmaxPasswordAge
    }

  
    $expireson = $passwordsetdate + $maxPasswordAge
    $today = (get-date)
    $daystoexpire = (New-TimeSpan -Start $today -End $Expireson).Days
        
    # Set Greeting based on Number of Days to Expiry.

    # Check Number of Days to Expiry
    $messageDays = $daystoexpire

    if (($messageDays) -gt "0")
    {
        $messageDays = "Your password will expire in " + "$daystoexpire" + " days./ Su contraseña caducará en $daystoexpire días."
    }
    else
    {
        $messageDays = "Now you can no longer change your password / Ahora ya no puede cambiar su contraseña"
    }

    # Email Subject Set Here
    $subject= $messageDays
  
    # Email Body Set Here, Note You can use HTML, including Images.
     $body ="
    Dear $name,
    <p> Your E-MAIL Password will expire in $daystoexpire days<br><br>
    If your computer is in COSENTINOGROUP.NET, to change your password on a PC press CTRL+ALT+DEL and choose 'Change Password' <br>
    You can also change your password using the link: <a href=""https://passwordreset.microsoftonline.com""> https://passwordreset.microsoftonline.com </a><br>
    For any question please use the remedy ticket system <a href=""https://cosentino-myit.onbmc.com/dwp/app/""> https://cosentino-myit.onbmc.com </a>
    or call SPAIN & ROW T. +34 950 543232 - USA, CANADA & BRASIL: T. +1 786 686 5100 o Extension 9999 <br><br>
    Su contraseña de CORREO ELECTRÓNICO caducará en $daystoexpire días<br><br>
    Para cambiar tu contraseña en tu PC presiona CRT+ALT+SUPR y selecciona 'Cambiar una contraseña'<br>
    También puedes cambiar tu contraseña desde el enlace <a href=""https://passwordreset.microsoftonline.com/""> https://passwordreset.microsoftonline.com/ </a><br>
    Para dudas y consultas usa el sistema de tickets en Remedy <a href=""https://cosentino-myit.onbmc.com""> https://cosentino-myit.onbmc.com </a> 
    o llama desde SPAIN & ROW T. +34 950 543232 desde USA, CANADA & BRASIL: T. +1 786 686 5100 o a la Extensión 9999<br>
    <p>Thanks, <br> 
    <p>Business Technology<br>
    Cosentino, S.A.

    </P>"


   
    # If Testing Is Enabled - Email Administrator
    if (($testing) -eq "Enabled")
    {
        $emailaddress = $testRecipient
    } # End Testing

    # If a user has no email address listed
    if (($emailaddress) -eq $null)
    {
        $emailaddress = $testRecipient    
    }# End No Valid Email

    # Send Email Message
    if (($daystoexpire -ge "0") -and ($daystoexpire -lt $expireindays))
    {
        $sent = "Yes"
        # If Logging is Enabled Log Details
        if (($logging) -eq "Enabled")
        {
            Add-Content $logfile "$date,$Name,$emailaddress,$daystoExpire,$expireson,$sent" 
        }
        # Send Email Message
        Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -priority High -Encoding $textEncoding   

    } # End Send Message
    else # Log Non Expiring Password
    {
        $sent = "No"
        # If Logging is Enabled Log Details
        if (($logging) -eq "Enabled")
        {
            Add-Content $logfile "$date,$Name,$emailaddress,$daystoExpire,$expireson,$sent" 
        }        
    }
    
} # End User Processing



# End