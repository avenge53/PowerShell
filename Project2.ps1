# Get Active Directory #
Import-Module ActiveDirectory

# Identify objects #
$availableWorkstations = @('LON-CL1','SVR-CL1', 'LON-DC1')

# Identify software package #
$softwarepackage = $software
$Installerpath = "E:\clamwin-0.103.2.1-setup.exe"

# Loop to add up to 10 users #
for ($u=0; $u -lt 10; $u++)
{ 
        
    # Create user #
    $username = Read-Host "Enter the username of the new employee" 
    $securepassword = Read-Host "Enter the password of the new employee" -AsSecureString 
    $Firstname = Read-Host "Enter the First name of the new employee"
    $Lastname = Read-Host "Enter the Last name of the new employee"
    
    New-ADUser -Name "$FirstName $LastName" -GivenName $Firstname -Surname $Lastname -UserPrincipalName $username -SamAccountName $username -Enabled $true -AccountPassword $securepassword 
   
    #...rest of user input #
    # Add user to group #
    $groups = Read-Host "Enter the user group for new employee (comma-separated)"
    $groupArray = $groups -split ","
    $groupArray | Foreach-Object { Add-ADGroupMember -Identity $_.Trim() -Members $username}
   
    # Assign first available workstation #
    $workstation = $availableWorkstations[0] 

    { 
        if ($availableWorkstations.Length -eq 0) 
            {
            Write-Output "No more available workstations."
            break
            }
    }

    # Remove assigned workstation #
    $availableWorkstations = $availableWorkstations[1..($availableWorkstations.Length - 1)] 

    # Install software on workstation #
    Foreach ($software in $softwarepackage) 
    {
        Invoke-Command -ComputerName $workstation -ScriptBlock | out-null
        {
        Start-Process -FilePath $InstallerPath -ArgumentList "/S" -Wait
        Write-Output "Installing $software on $workstation"
        }
    } 
    
    $manageremail = Read-Host "Enter the manager's email of the new employee"
   
    # Send a welcome email with login details to the employee's manager (using Send-MailMessage cmdlet) #
        $emailParams = @{
        To         = $managerEmail
        From       = "admin@Adatum.com"
        Subject    = "Welcome $FirstName $LastName"
        Body       = "Hello, `$n`n$FirstName $LastName has been onboarded successfully. Their username is $userName. `$n`nThanks,`$nIT Team"
                        }


}


