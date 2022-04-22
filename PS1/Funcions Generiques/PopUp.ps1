#### OPCIO 1

[System.Windows.MessageBox]::Show("Finalitzat. Revisa el LOG generat", "Informacio", "Ok", "Information")

#### OPCIO 2
#intButton = object.Popup(strText,[nSecondsToWait],[strTitle],[nType]) 

$wshell = New-Object -ComObject Wscript.Shell
$popup = $wshell.Popup("Operation Completed",0,"Done",0x1 + 0x20)

#### BUTONS DEL POPUP
#0x0	Show OK button.
#0x1	Show OK and Cancel buttons.
#0x2	Show Abort, Retry, and Ignore buttons.
#0x3	Show Yes, No, and Cancel buttons.
#0x4	Show Yes and No buttons.
#0x5	Show Retry and Cancel buttons.
#0x6	Show Cancel, Try Again, and Continue buttons.

#### ESTIL POPUP
#0x10	Show "Stop Mark" icon.
#0x20	Show "Question Mark" icon.
#0x30	Show "Exclamation Mark" icon.
#0x40	Show "Information Mark" icon.

#### ALTRES
#0x100	The second button is the default button.
#0x200	The third button is the default button.
#0x1000	The message box is a system modal message box and appears in a topmost window.
#0x80000	The text is right-justified.
#0x100000	The message and caption text display in right-to-left reading order, which is useful for some languages.

#### VALOR DE RETORN
#-1	The user did not click a button before nSecondsToWait seconds elapsed.
#1	OK button
#2	Cancel button
#3	Abort button
#4	Retry button
#5	Ignore button
#6	Yes button
#7	No button
#10	Try Again button
#11	Continue button
