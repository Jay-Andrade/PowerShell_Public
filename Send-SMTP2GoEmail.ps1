#Contributors: Briangig

#LEGACY - Moved to Send-SMTPMessage function in SAToolkit
#https://github.com/Jay-Andrade/SAToolkit/blob/main/Functions/Send-SMTPMessage.ps1

function Send-SMTP2GoEmail {
    $API_key = Read-Host "Enter API key for SMTP2Go"

    Param (
        [Parameter(Mandatory = $true)]$EmailRecipient,
        [Parameter(Mandatory = $true)]$emailsender,
        [Parameter(Mandatory = $true)]$subject,
        [Parameter(Mandatory = $true)]$textbody,
        [Parameter(Mandatory = $false)]$htmlbody = $textbody
    )

$jsonpayload = @"
    {
    "api_key": $API_key,
    "to": ["<$($EmailRecipient)>"],
    "sender": "$emailsender",
    "subject": "$subject",
    "text_body": "$textbody",
    "html_body": "$htmlbody"
    }
"@
    try {
        $response = Invoke-RestMethod 'https://api.smtp2go.com/v3/email/send' -Method 'POST' -Body $jsonpayload -ContentType "application/json"
        if ($response.data.succeeded -eq 1) {
            $result = "Successfully sent E-Mail."
        }
    }
    catch {
        $exceptionMessage = $_.Exception.Message
        $result = $exceptionMessage  
    }
    
    Return $result
}

#Send-SMTP2GoEmail -subject "This is a function test" -text_body "This is just a test of the function!!"