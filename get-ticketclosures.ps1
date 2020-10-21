$query = query-WorkItems -org asc-solutions -projectName drpl-compliance -QueryID 13451624-45d0-4da9-a22e-6de84476b437
$report = @()

foreach ($id in $query.workitems) {
    $response = list-AZdevopsWorkItems -org asc-solutions -projectName DRPL-Compliance -id $id.id

    $hashfields = $response.fields

    $WiId = $response.id
    $date = $hashfields."System.CreatedDate"
    $Wicreated = $date
    $WiType = $hashfields."System.WorkItemType"
    $Wiclosed = $hashfields."Microsoft.VSTS.Common.ClosedDate"

    #Write-host "$WiID created $Wicreated"
    #Write-host "$WiID closed $wiclosed"
    #get-date $Wicreated |fl
    #Get-Date $Wicreated

    $workDays = Get-WorkingDays -Startdate $Wicreated -Enddate $Wiclosed
    #Write-host "Number of working days between ticket opening and closing = $workdays"

    $time = New-TimeSpan –Start $Wicreated –End $Wiclosed
    $days = $time.days
    $hours = $time.hours
    $minutes = $time.minutes
    #$time
    #$hashfields
    #Write-Host "show date start create"
    #$date
    #Write-Host "show date closed"
    #$Wiclosed

    $WiObject = New-Object psobject
    $WiObject | Add-Member -Type NoteProperty -Name WorkItemType -Value $WiType
    $WiObject | Add-Member -Type NoteProperty -Name WorkItemID -Value $WiId
    $WiObject | Add-Member -Type NoteProperty -Name DaysElapsed -Value $days
    $WiObject | Add-Member -Type NoteProperty -Name hoursElapsed -Value $hours
    $WiObject | Add-Member -Type NoteProperty -Name MinutesElapsed -Value $minutes
    $report += $WiObject
}
$report