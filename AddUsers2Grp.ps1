Install-WindowsFeature -Name RSAT-AD-PowerShell

Import-Module ActiveDirectory

new-ADgroup 'Engineers' -Path 'OU=Managers,DC=adatum,DC=com' -GroupScope Global -GroupCategory Security

$users = @('Alfie Power', 'Erin Bull', 'Sarah Burch')

$groupname = 'Engineers'

$resolvedUsers = @()

foreach ($displayName in $users) 
{
    $userSamAccountName = (Get-ADUser -Filter "Name -eq '$displayName'").samAccountName

    if ($userSamAccountName) 
    {
        $resolvedUsers += $userSamAccountName
    } 
    else 
    {
        Write-Warning "User with display name $displayName not found."
    }
}
foreach ($user in $resolvedusers)
{
    Add-ADGroupMember -Identity $groupname -Members $user
}





