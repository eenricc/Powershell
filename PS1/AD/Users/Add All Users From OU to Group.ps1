﻿Get-ADUser -SearchBase ‘OU=07 EXTERNAL USERS,OU=-001 COSENTINO USERS,DC=cosentinogroup,DC=net’ -Filter * | ForEach-Object {Add-ADGroupMember -Identity ‘Externos’ -Members $_ }