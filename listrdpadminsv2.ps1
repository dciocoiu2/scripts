# Import the required assemblies
[reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[reflection.assembly]::LoadWithPartialName("System.DirectoryServices") | Out-Null

# Create a form to prompt the user for their credentials and domain name
$form = New-Object System.Windows.Forms.Form
$form.Text = "Enter Credentials"
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = "CenterScreen"

# Add a label for the username
$usernameLabel = New-Object System.Windows.Forms.Label
$usernameLabel.Location = New-Object System.Drawing.Point(10,20)
$usernameLabel.Size = New-Object System.Drawing.Size(280,20)
$usernameLabel.Text = "Username:"
$form.Controls.Add($usernameLabel)

# Add a text box for the username
$usernameTextBox = New-Object System.Windows.Forms.TextBox
$usernameTextBox.Location = New-Object System.Drawing.Point(10,40)
$usernameTextBox.Size = New-Object System.Drawing.Size(280,20)
$form.Controls.Add($usernameTextBox)

# Add a label for the password
$passwordLabel = New-Object System.Windows.Forms.Label
$passwordLabel.Location = New-Object System.Drawing.Point(10,70)
$passwordLabel.Size = New-Object System.Drawing.Size(280,20)
$passwordLabel.Text = "Password:"
$form.Controls.Add($passwordLabel)

# Add a text box for the password
$passwordTextBox = New-Object System.Windows.Forms.TextBox
$passwordTextBox.Location = New-Object System.Drawing.Point(10,90)
$passwordTextBox.Size = New-Object System.Drawing.Size(280,20)
$passwordTextBox.PasswordChar = "*"
$form.Controls.Add($passwordTextBox)

# Add a label for the domain name
$domainLabel = New-Object System.Windows.Forms.Label
$domainLabel.Location = New-Object System.Drawing.Point(10,120)
$domainLabel.Size = New-Object System.Drawing.Size(280,20)
$domainLabel.Text = "Domain Name:"
$form.Controls.Add($domainLabel)

# Add a text box for the domain name
$domainTextBox = New-Object System.Windows.Forms.TextBox
$domainTextBox.Location = New-Object System.Drawing.Point(10,140)
$domainTextBox.Size = New-Object System.Drawing.Size(280,20)
$form.Controls.Add($domainTextBox)

# Add a button to submit the form
$submitButton = New-Object System.Windows.Forms.Button
$submitButton.Location = New-Object System.Drawing.Point(10,170)
$submitButton.Size = New-Object System.Drawing.Size(280,30)
$submitButton.Text = "Submit"
$submitButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.Controls.Add($submitButton)
$form.AcceptButton = $submitButton

# Show the form and get the user's input
$result = $form.ShowDialog()

# If the user clicked the submit button, retrieve the local administrators and Remote Desktop users
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
  # Create an empty array to store the results
  $results = @()
  
  # Read the list of remote servers from a file
  $serverList = Get-Content "C:\serverlist.txt"
  
  # Iterate through the list of remote servers
  foreach ($server in $serverList) {
    # Connect to the remote server using the user's credentials
    $connection = New-Object System.DirectoryServices.DirectoryEntry("WinNT://$server", $usernameTextBox.Text, $passwordTextBox.Text)
    
    # Get the local administrator accounts
    $localAdmins = [System.Collections.ArrayList]$connection.Invoke("Members") | % {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)} | Where-Object {$_ -like "Administrator*"}
    
    # Get the local Remote Desktop users
    $localRDP = net localgroup "Remote Desktop Users" /domain | Select-String -Pattern $server | ForEach-Object {$_.ToString().Split(" ")[-1]}
    
    # Add the results for this server to the array
    $results += [pscustomobject]@{
      Server = $server
      "Local Admins" = $localAdmins -join ", "
      "Local RDP users" = $localRDP -join ", "
    }
  }
  
  # Output the results to a CSV file
  $results | Export-Csv "C:\output.csv" -NoTypeInformation
}
