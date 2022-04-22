#DADES DEL SEVIDOR DE CORREU
$smtpServer="172.29.3.13"
$from = "COSENTINO OUS INCORRECTAS <helpdesk@cosentino.com>"
$Subject = "Equipos OUs incorrectas"
$textEncoding = [System.Text.Encoding]::UTF8
$body = "
Hola,
<p>
Adjunto los equipos ubicados en OUs incorrectas a fecha: $databe
<p>
Saludos,
"

#ENVIEM CORREU
Send-Mailmessage -smtpServer $smtpServer -from $from -to 'enric.ferrer@t-systems.com' -subject $subject -body $body -bodyasHTML -priority High -Encoding $textEncoding -Attachments "C:\ts_data\MWS\Reports\Export_OU_Incorrecta_$data.csv"