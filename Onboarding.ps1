# Get Active Directory #
Import-Module ActiveDirectory

# Identify objects #
$AvailableWorkstations = @('LON-CL1', 'LON-SVR1', 'LON-DC1')

# Identify software package #
$SoftwareName = "Git"
$Software = 'E:\Git-2.42.0.2-64-bit.exe'
$SoftwarePackage = $Software


# Allow PowerShell remoting to all workstations #
Enable-PSRemoting

# Create firewall rule for remote installation #
$Session = New-PSSession -ComputerName LON-DC1, LON-DC1, LON-SVR1 
       
Invoke-Command -Session $Session -ScriptBlock {
    
    New-NetFirewallRule -DisplayName "Allow WinRM over HTTPS" -Direction Inbound -LocalPort 5986 -Protocol TCP -Action Allow
}


# Loop to add up to 10 users #
for ($u = 0; $u -lt 10; $u++) { 
        
    # Create user #
    $UserName = Read-Host "Enter the username of the new employee" 
    $SecurePassword = Read-Host "Enter the password of the new employee" -AsSecureString 
    $FirstName = Read-Host "Enter the First name of the new employee"
    $LastName = Read-Host "Enter the Last name of the new employee"
    
    New-ADUser -Name "$FirstName $LastName" -GivenName $FirstName -Surname $LastName -UserPrincipalName $Username -SamAccountName $Username -Enabled $true -AccountPassword $SecurePassword 
   
    # Input additional user details and add user to group #
    $Groups = Read-Host "Enter the user group for new employee (comma-separated)"
    $GroupArray = $Groups -split ","
    $GroupArray | Foreach-Object { Add-ADGroupMember -Identity $_.Trim() -Members $UserName }
    
    if ($AvailableWorkstations.Length -eq 0) {
        Write-Output "No more available workstations."
        break
    }
   
    # Assign first available workstation #
    $WorkStation = $AvailableWorkstations[0]     
    
    # Remove assigned workstation #
    $AvailableWorkstations = $AvailableWorkstations[1..($AvailableWorkstations.Length - 1)] 

    # Install software on workstation #
    Foreach ($Software in $SoftwarePackage) {
        Invoke-Command -ComputerName $WorkStation -ScriptBlock {
       
            Start-Process -FilePath $Software -ArgumentList "/S" -Wait 
        }   
        
        Write-Output "Installing $SoftwareName on $WorkStation"
    }

    # Verify software installation #    
    $InstalledSoftware = Invoke-Command -ComputerName $WorkStation -ScriptBlock {
            
        Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName
    } 
            
    if ($InstalledSoftware.DisplayName -contains $SoftwareName) {
        Write-Output "$SoftwareName is installed on $WorkStation."
    } 
    else {
        Write-Output "$SoftwareName is NOT installed on $WorkStation."
    }

        
}


