# Veure comptes blocats
Search-ADAccount -lockedout | select name

# Desbloqueig masiu
Search-ADAccount -lockedout | Unlock-ADAccount

# Per veure directament a dsa.msc
#(&(objectCategory=Person)(objectClass=User)(lockoutTime>=1))