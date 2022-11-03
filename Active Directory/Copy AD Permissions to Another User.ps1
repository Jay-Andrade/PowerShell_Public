$Username1 = Read-Host "Enter the user to copy permissions FROM"
$Username2 = Read-Host "Enter the user to copy permissions TO"

$CopyFromUser = Get-ADUser $Username1 -prop MemberOf
$CopyToUser = Get-ADUser $Username2 -prop MemberOf
$CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Members $CopyToUser