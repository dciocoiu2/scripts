# Set the computer name and credentials
$computerName = "server1"
$username = "domain\username"
$password = ConvertTo-SecureString "password" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

# Connect to the WMI namespace on the remote computer
$namespace = "root\cimv2"
$options = New-CimSessionOption -Protocol Dcom
$session = New-CimSession -ComputerName $computerName -Credential $credential -Namespace $namespace -SessionOption $options

# Query the installed updates on the remote computer
$query = "SELECT * FROM Win32_QuickFixEngineering"
$updates = Get-CimInstance -CimSession $session -Query $query

# Display the update information
$updates | Select-Object HotFixID, Description, InstalledOn | Format-Table -AutoSize

# Disconnect from the remote computer
Remove-CimSession -CimSession $session
