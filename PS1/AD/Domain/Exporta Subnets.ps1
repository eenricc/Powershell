## EXPORTAR SUBENTS ## VALID PER WIN2012 O MES ##
get-adreplicationsubnet -filter * -Properties * | select-object name, site, description | export-csv subnets.csv