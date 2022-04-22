# LLISTA EQUIPS AMB SAMACCOUNTNAME
$Pclist = Get-Content C:\Users\enric.ferrer\Desktop\Computers.txt

Foreach($pc in $Pclist){
    Disable-ADAccount -Identity "$pc"
}