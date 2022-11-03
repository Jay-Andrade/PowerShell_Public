Connect-ExchangeOnline

$Userid = Read-Host "Enter the email address of the user"
$InternalMessage = Read-Host "Enter the internal OOO here"
$ExternalMessage = Read-Host "Enter the external OOO here --or-- enter 'same' to use the internal OOO"

if ($ExternalMessage.toLower() -eq "same") {
    $ExternalMessage = $InternalMessage
    Write-Host "Using the same message for internal and external OOO."
}

Set-MailboxAutoReplyConfiguration -Identity $Userid -AutoReplyState Enabled -InternalMessage $InternalMessage -ExternalMessage $ExternalMessage

Write-Host "Enabled an OOO for $Userid."
