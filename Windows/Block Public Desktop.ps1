#Contributor: Briangig
#Not sure why you'd ever want to do this but if you do... here you go.

#Check
$Acl = Get-Acl -Path C:\Users\Public\Desktop
$Ace = $Acl.Access | Where-Object {($_.IdentityReference -like "*\Users*") -and -not ($_.IsInherited)}
if ($ace) {
    #ACL is present, do nothing, return true
    $ACLFound = "Yes"
}
else {
    #ACL is missing, apply, then check again

    #Implement
    $user = Get-LocalGroup -Name "Users"
    $Inheritance = 'ContainerInherit, ObjectInherit'
    $Propagation = 'None'
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($user,"Read",$inheritance,$Propagation,"Deny")
    $ACL = Get-Acl -Path C:\Users\Public\Desktop
    $ACL.AddAccessRule($AccessRule)
    $ACL | Set-Acl -Path C:\Users\Public\Desktop

    #Recheck
    $ACL = Get-Acl -Path C:\Users\Public\Desktop
    if ($ace) {
        #ACL is present, do nothing, return true
        $ACLFound = "Yes"
    }
    else {
        $ACLFound = "No"
    }
}

# Undo
# $Acl = Get-Acl -Path C:\Users\Public\Desktop
# $Ace = $Acl.Access | Where-Object {($_.IdentityReference -like "*\Users*") -and -not ($_.IsInherited)}
# $Acl.RemoveAccessRule($Ace)
# Set-Acl -Path C:\Users\Public\Desktop -AclObject $Acl