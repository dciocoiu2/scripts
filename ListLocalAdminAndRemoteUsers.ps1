# Get a list of the local admins and remote desktop users from a provided list of servers
#
# Usage:
# >     .\ListServerLocalAdmins -serverList '.\Servers.txt' -outputFile ".\Output.csv" -errorFile ".\Errors.csv"
#
#

Param
(  
    [CmdletBinding(SupportsPaging = $true)]
    [Parameter(Mandatory=$false)]
    [String]
    $serverList = ".\Servers.txt",
    $outputFile = ".\Output.csv",
    $errorFile = ".\Errors.csv"
) 

Begin
{
    # init 
    $i = 0
    $percentage = 0    
    $totalServers = (Get-Content $serverList | Measure-Object -Line).Lines
}

Process
{
    # Create file (override if exists) and add header
    Set-Content -Path $outputFile -Value '"Group","Domain","Users","Computer"' -Encoding Unicode
    Set-Content -Path $errorFile -Value '"Computer","Error"' -Encoding Unicode
    # loop through each server in the list
    foreach($computerName in Get-Content $serverList) {                
        try
        {           
            # List all local Admins and Remote Users
            $groups = Get-WmiObject win32_groupuser –computer $computerName   
            $groups = $groups | Where-Object { ($_.groupcomponent –match 'Administrators') -or ($_.groupcomponent –match 'Remote')}  
            $groups | ForEach-Object {                                 
                $_.groupcomponent –match "Name\=(.+)$" > $nul  # get group name
                $values = """" + $matches[1].trim('"') + """,""" 
                $_.partcomponent –match ".+Domain\=(.+)\,Name\=(.+)$" > $nul  # get user domain and user name
                $values = $values + $matches[1].trim('"') + """,""" + $matches[2].trim('"') + """,""" + $computerName + """" # concatenate all and add computer name
                $values | Out-File -FilePath $outputFile -Append -Encoding Unicode # save to file
            }
        }
        catch   
        {
            #Write to console
            $lastError = $Error[0].ToString()
            Write-Host $computerName $lastError -NoNewline             
            #remove new line from the end of the string
            $lastError = $lastError.TrimEnd("`r?`n") 
            # Write to errors file 
            """$computerName"",""$lastError""" | Out-File -FilePath $errorFile -Append
        }    
        # calculate percent complete
        $i = $i + 1
        $percentage = [math]::Round((($i / $totalServers) * 100))
        Write-Host "Percentage complete..." $percentage "%"
    } 
}

End
{
    # cleanup
}