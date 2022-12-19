# Import the required assemblies
[reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[reflection.assembly]::LoadWithPartialName("System.DirectoryServices") | Out-Null

# Prompt the user for their credentials and domain name using a GUI menu
$credential = $host.ui.PromptForCredential("Enter Credentials", "Enter your domain credentials", "", "")
$domainName = [System.Windows.Forms.InputBox]::Show("Enter Domain Name", "Enter the domain name:", "")

# Create an empty array to store the results
$results = @()

# Read the list of remote servers from a file
$serverList = Get-Content "C:\serverlist.txt"

# Iterate through the list of remote servers
foreach ($server in $serverList) {
  # Connect to the remote server using the user's credentials
  $connection = New-Object System.DirectoryServices.DirectoryEntry("WinNT://$server", $credential.Username, $credential.GetNetworkCredential().password)
  
  # Get the local administrator accounts
  $localAdmins = [System.Collections.ArrayList]$connection.Invoke("Members") | % {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)} | Where-Object {$_ -like "Administrator*"}
  
  # Get the local Remote Desktop users
  $localRDP = net localgroup "Remote Desktop Users" /domain | Select-String -Pattern $server | ForEach-Object {$_.ToString().Split(" ")[-1]}
  
  # Add the results for this server to the array
  $results += [pscustomobject]@{
    "Local Admin" = $localAdmins -join ", "
    "Local RDP" = $localRDP -join ", "
    "Server Name" = $server
  }
}

# Output the results to a CSV file
$results | Export-Csv "C:\output.csv" -NoTypeInformation
