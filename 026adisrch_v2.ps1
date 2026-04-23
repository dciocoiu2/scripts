#adisrch.ps1 
# Display name / first / last name (wildcard search) 
# $name="username";([adsisearcher]"(&(objectCategory=person)(objectClass=user)(|(displayName=*$name*)(givenName=*$name*)(sn=*$name*)))").FindAll()|ForEach-Object{Write-Host "OU:$($_.Path)";$_.Properties.memberof}|Format-Wide 
# Any common identifier (display name, email, UPN, samAccountName) 
#$name="username";([adsisearcher]"(&(objectClass=user)(|(displayName=*$name*)(mail=*$name*)(userPrincipalName=*$name*)(sAMAccountName=*$name*)))").FindAll()|ForEach-Object{$_.Properties.displayname} 
#`` 
# name + ou 
#([adsisearcher]"(&(objectClass=user)(displayName=*username*))").FindAll()|ForEach-Object{$_ .Path} 
# UPN from sAMaccount 
# ([adsisearcher]"(&(objectClass=user)(sAMAccountName=jdoe))").FindOne().Properties.userprincipalname 
#``