Import-Module ActiveDirectory

function DeleteUserFiles {
    # Get the list of users from the text file
    $users = Get-Content "C:\Users\Username\Desktop\users.txt"

    # Loop through the list of users
    foreach ($user in $users) {
        # Check if the user exists and is enabled in Active Directory
        $adUser = Get-ADUser $user -ErrorAction SilentlyContinue
        if ($adUser -eq $null -or $adUser.Enabled -eq $false) {
            # Delete the user's files from the shared folder
            Remove-Item "S:\$user" -Recurse -Force
        }
    }
}

# Call the function to delete the user files
DeleteUserFiles
