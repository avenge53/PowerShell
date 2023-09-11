Install-WindowsFeature -Name RSAT-AD-PowerShell

Import-Module ActiveDirectory

new-ADgroup 'Engineers' -Path 'OU=Managers, DC=adatum, DC=com' -GroupScope Global -GroupCategory Distribution

$users = @("Alfie Power", "Erin Bull", "Sarah Burch")

$groupname = @('Engineers')

foreach ($user in $users){
    Add-ADGroupMember -Identity $groupname -Members $users
}





