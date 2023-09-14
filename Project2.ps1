# Get Active Directory #
Import-Module ActiveDirectory

# Identify objects #
$availableWorkstations = @('LON-CL1','LON-SVR1', 'LON-DC1')

# Identify software package #
$softwareName = "Git"
$softwarepackage = $software


# Loop to add up to 10 users #
for ($u=0; $u -lt 10; $u++)
{ 
        
    # Create user #
    $username = Read-Host "Enter the username of the new employee" 
    $securepassword = Read-Host "Enter the password of the new employee" -AsSecureString 
    $Firstname = Read-Host "Enter the First name of the new employee"
    $Lastname = Read-Host "Enter the Last name of the new employee"
    
    New-ADUser -Name "$Firstname $Lastname" -GivenName $Firstname -Surname $Lastname -UserPrincipalName $username -SamAccountName $username -Enabled $true -AccountPassword $securepassword 
   
    #...rest of user input #
    # Add user to group #
    $groups = Read-Host "Enter the user group for new employee (comma-separated)"
    $groupArray = $groups -split ","
    $groupArray | Foreach-Object { Add-ADGroupMember -Identity $_.Trim() -Members $username}
   
    # Assign first available workstation #
    $workstation = $availableWorkstations[0] 

     
        if ($availableWorkstations.Length -eq 0)
            {
            Write-Output "No more available workstations."
            break
            }
    

    # Remove assigned workstation #
    $availableWorkstations = $availableWorkstations[1..($availableWorkstations.Length - 1)] 

    # Install software on workstation #
    $InstallerPath = 'E:\Git-2.42.0.2-64-bit.exe'
    
    Foreach ($software in $softwarepackage) 
        {
        Invoke-Command -ComputerName $workstation -ScriptBlock
            {
        Start-Process -FilePath ${using}$InstallerPath -ArgumentList "/S" -Wait 
            } 
        
            Write-Output "Installing $softwareName on $workstation"
        }

    # Verify software installation #    
      $installedSoftware = Invoke-Command -ComputerName $workstation -ScriptBlock {}
            
            Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName
             
            
        if ($installedSoftware.DisplayName -contains $softwareName) 
            {
            Write-Output "$softwareName is installed on $workstation."
            } 
      else  
            {
            Write-Output "$softwareName is NOT installed on $workstation."
            }

       
                        



}


