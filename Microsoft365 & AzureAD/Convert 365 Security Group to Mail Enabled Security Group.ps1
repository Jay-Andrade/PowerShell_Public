#Exports all users in an existing Microsoft 365 Security Group and creates a new
#Mail Enabled Security Group (MESG) with the same members

#Custom function I haven't found a way around using
function Split-Var($var) {
    $var = $var -split "(=)"
    $var = $var[2]
    $var = $var -split "(})"
    Return $var[0]
}

#Connect to AAD and Exchange Online
Connect-AzureAD
Connect-ExchangeOnline

#Gather information from user
$aadgroup = Read-Host "Enter name of AzureADGroup:"
$exchangegroupname = Read-Host "Enter Display Name for new Mail Enabled Security Group"
$exchangegroupalias = Read-Host "Enter alias for new Mail Enabled Security Group"
$exchangegroupsmtp = Read-Host "Enter the Primary SMTP Address for the new Mail Enabled Security Group"

#Export current members in AAD Security Group
$aadgroupid = Split-Var(Get-AzureADGroup -SearchString $aadgroup | select ObjectId)
Get-AzureADGroupMember -ObjectId $aadgroupid | select mail | Export-CSV 'C:\temp\aadgroup.csv'

#Create new Mail Enabled Security Group (MESG)
New-DistributionGroup -Name $exchangegroupname -Alias $exchangegroupalias -Type "Security" -PrimarySmtpAddress $exchangegroupsmtp -HiddenGroupMembershipEnabled -MemberDepartRestriction 'Closed' -MemberJoinRestriction 'Closed'

#Import members then add each one to new MESG
$exchangegroupmembers = Import-CSV 'C:\temp\aadgroup.csv'
ForEach($exchangegroupmember  in $exchangegroupmembers) {
    $User = $exchangegroupmember."Mail"

    Try {
        #Add member to the group
        Add-DistributionGroupMember -Identity $exchangegroupname -Member $User -ErrorAction Stop
    }
    catch {
        Write-Host "Error occurred for $User" -f Yellow
        Write-Host $_ -f Red
    }
}

Remove-Item C:\temp\aadgroup.csv