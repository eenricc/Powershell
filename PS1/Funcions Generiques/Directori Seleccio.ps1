#### FORMAT
#intButton = object.BrowseForFolder(Hwnd,sTitle,iOptions,vRootFolder) 

$app = New-Object -ComObject Shell.Application
$folder = $app.BrowseForFolder(0, "Selecciona carpeta", 0, "")
if ($folder) { $selectedDirectory = $folder.Self.Path } else { $selectedDirectory = '' }
return $selectedDirectory

#### OPCIONS
# Hwnd  - Identificador de la ventana primaria del cuadro de diálogo. Este valor puede ser cero.   
# sTitle - Valor string que representa el título que se muestra dentro del cuadro de diálogo Examinar.
# iOptions - Valor Entero que contiene las opciones para el método . Puede ser cero o una combinación de los valores enumerados en el miembro ulFlags de la estructura BROWSEINFO.
# vRootFolder - Carpeta raíz que se usará en el cuadro de diálogo. El usuario no puede examinar más arriba en el árbol que esta carpeta. Si no se especifica este valor, la carpeta raíz que se usa en el cuadro de diálogo es el escritorio.
