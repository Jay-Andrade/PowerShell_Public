Import-Module "SAToolkit"

#Search for last RunProfileName matching Export (Search for logs in the range of the last completed scan)
#Export is the last profile to be run as a part of a syncronization so using the last export time will give us the last time the sync ran in full
#Prevents monitor flapping due to a scan happening during a syncronization and any potential errors not happening yet in that cycle
$lastSyncStart = (Get-ADSyncRunProfileResult | Sort-Object RunNumber,CurrentStepNumber -Descending | Select-Object -First 3 | Where-Object -FilterScript {$_.RunProfileName -like 'Export'}).StartDate

$events = (Get-WinEvent -FilterHashtable @{ProviderName='ADSync'; StartTime=$lastSyncStart} -ErrorAction SilentlyContinue)
$eventIDs = @(106,109,6801,6803,6941,6012,6100,6105,6110,6126,6127) #Known list of eventlog IDs indicating a problem
$errorEvents = ''

foreach ($item in $events) {
    if ($eventIDs.Contains($item.id)) {
        $errorEvents += ($item.message + "`n") 
    }
}

if (!($errorEvents)) {
    $status = 'OK'
    Write-Syslog -Category 'INFO' -Message "ADConnect status is OK, no error event logs found during last complete syncronization."
} else {
    $errorEvents = $errorEvents.Substring(0,$errorEvents.Length-2) #Trims trailing newline character
    $status = $errorEvents
    Write-Syslog -Category 'WARN' -Message "ADConnect status is Failed. Found error event logs during last complete syncronization. Error(s): $status"
}