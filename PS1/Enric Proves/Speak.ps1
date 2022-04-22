Add-Type -AssemblyName System.Speech
$Speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$text = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("SG9sYSwgc295IHVuIHJvYm90IEVORkFOVEUh"))
$speak.speak($text)

#CODIFICA TEXT
#https://www.base64encode.org/

#EXPORTAR A WAV:
#$Speak.SetOutputToWaveFile("C:\users\Administrator\Desktop\test.wav")
#$Speak.Dispose()
#VEUS INSTALADES
#$speak.GetInstalledVoices().VoiceInfo
#CANVI DE VEU
#$speak.SelectVoice('Microsoft Zira Desktop')

