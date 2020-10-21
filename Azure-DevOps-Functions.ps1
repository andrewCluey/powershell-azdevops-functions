function create-userStory {
    param(
        [string]$project,
        [string]$wiType, 
        [string]$opType,
        [string]$SrcWiURL,
        [string]$SourceProject,
        [string]$from, 
        [string]$TitleValue,
        [string]$DescriptionValue,
        [string]$SourceID,
        [string]$org
        )
<#
.SYNOPSIS
Create a new User Story Work Item in the given Project.
    
.DESCRIPTION
Long description
  
.PARAMETER project
The name of the Azure DevOps project where the new Work Item should be created.
    
.PARAMETER wiType
The type of Work item to create. options are:
    - User Story (default)
----- NOT CURRENTLT OPERATIONAL ------
--- To added in a future Release. -----
---- Future release will enable other work item types to be created. Meaning this function has wider use cases.

.PARAMETER opType
Defaults to 'ADD'
--- NOT CURRENTLY OPERATIONAL ---
--- This is currently hard coded into the function code ---

.PARAMETER SrcWiURL
The URL of the original Work Item from the Source project.

.PARAMETER SourceProject
The Source project Name. 
Only used for the Http Trigger Azure Function App when creating an Infrastructure User Story for project infrastructure Requests.

.PARAMETER from
Parameter description
---- No current use ---
    
.PARAMETER TitleValue
Parameter description
    
.PARAMETER Description
Parameter description

.PARAMETER org
Parameter description

.EXAMPLE
create-userStory -project "test-destination" -wiType bug -value "test value 14:35 ASC" -org "rubix-group"

.EXAMPLE
Add further examples when new features added in future versions.

.NOTES
Future Release Enhancements:
    WiURL is currently coded to create all entries as a new User Story. 
      - This is for our primary use case of requiring all Work Items to appear in the INFRA Kanban Board.
      - Future release will mean this can be used for other use cases. Not just Infra Kanban board WIs.

    Project Parameter is currently hard coded to create all entries in the 'Infra-team' project.
      - This is for our primary use case of requiring all Work Items to appear in the INFRA Kanban Board.
      - Future release will mean this can be used for other use cases. Not just Infra Boards.

    Add extra content. Such as:
      - Created BY in Description
      - Add a title in subject.
      - date Created in Description
#>

# These VARS are for testing only.
# $Description = "<div>This is the description for 2nd user Story test</div><div>&nbsp; - Project name: test Source</div><div>&nbsp; - Created by: Andrew Clure</div>"
# $SrcWiURL    = "https://dev.azure.com/test-source/wi"

# Set internal variables.
$WiURL = "https://dev.azure.com/$org/$project/_apis/wit/workitems/`$User%20Story?api-version=6.0-preview.3"
$originURL = https://dev.azure.com/$org/$project/_workitems/edit/$id
$DescriptionValue = $Description

# Create API body
$jsonBase = @{}
$list = New-Object System.Collections.ArrayList
$list.Add(@{"op"="add";"path"="/fields/System.Title";"from"=$null;"value"="$TitleValue"})              # Create the json data for the Title of the WI
$list.Add(@{"op"="add";"path"="/fields/System.Description";"from"=$null;"value"="$DescriptionValue"})  # Create the json data for the Description of the WI
$jsonBase = $list
$json = ConvertTo-Json -InputObject $jsonBase

# Create new Work Item using the Azure DevOps API.
$response = Invoke-RestMethod -uri $wiURL -Method "POST" -Headers $header -Body $json -ContentType "application/json-patch+json"
$WiID = $response.id
Write-host "ID of the newly created Work item is $WiID"
}


############################################
# Function to List all Azure DevOps Projects
############################################
function list-AZdevopsProjects {
  param (
      [string]$org, 
      [string]$ProjectSuffix, 
      [string]$projectName, 
      [string]$wiSuffix
      )
<#
.SYNOPSIS
Lists all Azure DevOps projects created in a given organisation (-org)
https://github.com/PowerShell/Win32-OpenSSH/wiki/sshd_config

.DESCRIPTION
Long description

.PARAMETER org
The Azure DevOps Organization to query

.PARAMETER ProjectSuffix
Parameter description

.PARAMETER projectName
Parameter description

.PARAMETER wiSuffix
Parameter description

.EXAMPLE
list-AZdevopsProjects -org rubix-group

.NOTES
# FUTURE ENHANCEMENTS :
    - Format output in more readable table view
#>

$WiURL = "https://dev.azure.com/$org/_apis/projects?api-version=6.0-preview.3"
$response = Invoke-RestMethod -Uri $wiURL -Method Get -ContentType "application/json" -Headers $header
$name = $response.value.name

# Change this to output as a formatted table array
write-host "projects are $name"
}


#######################################################################
# Function to Connect to Azure DevOps API using a Personal Access Token
#######################################################################
function connect-AzureDevOps {
  param (
    [string]$PersonalToken
  )
  
<#
.SYNOPSIS
Connect to the Azure DevOps API.

.DESCRIPTION
Long description

.PARAMETER PersonalToken
The Personal Access Token to be used when authenticatin got the Azure DevOps API.

.EXAMPLE
connect-AzureDevOps -personalToken "BlahBlah12345"
#>

$token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalToken)"))
$header = @{"Authorization" = ("Basic {0}" -f $token)}
$header
}





#######################################################
# Function to List an Azure Devops Work Item by its ID.
#######################################################
function list-AZdevopsWorkItems {
  param (
    [string]$org,
    [string]$projectName,
    [string]$id
  )

<#
.SYNOPSIS
Lists all Azure DevOps WorkItems in a Given Project
https://github.com/PowerShell/Win32-OpenSSH/wiki/sshd_config

.DESCRIPTION
Long description

.PARAMETER org
The Azure DevOps Organization to query

.PARAMETER projectName
Parameter description

.PARAMETER id
The ID of the work item to retrieve.

.PARAMETER Header
The Authorisation heade rot use when connecting to the REST API (see function - "Connect-AzureDevOps")

.EXAMPLE
Connect-AzureDevOps -PersonalToken blahblahblah
list-AZdevopsWorkItems -org test-org -projectName New-Project -id 11

#>

$WIURL = "https://dev.azure.com/$org/$projectName/_apis/wit/workitems/$id"
$url = $WIURL + "?api-version=6.0-preview.3"

$response = Invoke-RestMethod -Uri $URL -Method Get -ContentType "application/json" -Headers $header
$id = $response.id
$hashfields = $response.fields
$date = $hashfields."System.CreatedDate"
$created = $date.DateTime
$closed = $hashfields."Microsoft.VSTS.Common.ClosedDate"

$response

#$Created = $response[fields.System.CreatedDate]
}





#####################################################################################
# Function to list Work Item Queries contained with a specified Azure DevOps Project
#####################################################################################
function get-queries {
  param (
    [string]$org,
    [string]$projectName
  )

  $Qurl = "https://dev.azure.com/$org/$projectName/_apis/wit/queries?"
  $url = $Qurl + '$depth=2&api-version=6.0'
  $response = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json" -Headers $header

  $url
  $response
}


###########################################################################
# Function to execute a given Query (using the Query ID) & view the results
###########################################################################
function Query-WorkItems {
  param (
    [string]$org,
    [string]$projectName,
    [string]$QueryID
  )
<#
.SYNOPSIS
Execute a specified Azure DevOps WorkItem query by its ID.

.DESCRIPTION
Long description

.PARAMETER org
The Azure DevOps Organization to connect to

.PARAMETER projectName
The name of the project that contains the Query.

.PARAMETER QueryID
The ID of the Query to execute

.EXAMPLE
$header = Connect-AzureDevOps -PersonalToken blahblahblah
query-WorkItems -org Az-Org -projectName new-project -QueryID 13451624-45d0-4da9-a22e-6de84476b437
#>

  $Qurl = "https://dev.azure.com/$org/$projectName/_apis/wit/wiql/$QueryID"
  $url = $Qurl + "?api-version=6.0"
  $response = Invoke-RestMethod -Uri $URL -Method Get -ContentType "application/json" -Headers $header

  $response
}





Function Get-WorkingDays
{
    Param
    (
        [Parameter(Position=0,Mandatory=$True)]
        [DateTime]$Startdate,
        [Parameter(Position=1,Mandatory=$False)]
        [DateTime]$Enddate
    )
     
    $StartHour = 8
    $FinishHour = 17
 
    # Enter whatever dates here you do not want to be included as part of your business days/hours calculation
    $holidays = @(
        (Get-Date -Date '2020-12-24')            # Labour Day
        (Get-Date -Date '2020-12-25')            # Thanksgiving
        (Get-Date -Date '2020-12-26')            # Christmas Holidays
        (Get-Date -Date '2020-12-31')            # Christmas Holidays
        (Get-Date -Date '2021-01-01')            # Christmas Holidays
        (Get-Date -Date '2021-04-12')            # Good Friday
        (Get-Date -Date '2021-04-15')               # Easter Monday
        (Get-Date -Date '2021-12-25')            # Christmas Holidays
        (Get-Date -Date '2021-12-26')            # Christmas Holidays
        (Get-Date -Date '2021-12-31')            # Christmas Holidays
        (Get-Date -Date '2022-01-01')            # Christmas Holidays
    )
 
    # If both a startdate and an enddate are provided, return the number of business days between the two
    if($Enddate)
    {
        $difference = New-TimeSpan -Start $startdate -End $enddate
        $days = [Math]::Ceiling($difference.TotalDays)
 
        $workdays = (1..$days) | ForEach-Object {
            $startdate
            $startdate = $startdate.AddDays(1)
        } | Where { $_.DayOfWeek -gt 0 -and $_.DayOfWeek -lt 6 -and $Holidays -notcontains $_.date } | Measure-Object | Select-Object -ExpandProperty Count
 
        return $Workdays
    } 
     
    # If an enddate is not provided return if the start date is within working hours or not
    else
    {
        $DayStatus = $startdate | Where { 
            $_.DayOfWeek -gt 0 -and # Not Sunday
            $_.DayOfWeek -lt 6 -and  # Not Saturday
            $Holidays -notcontains $_.date -and
            $startdate.hour -ge $StartHour -and
            $startdate.hour -lt $FinishHour
        } | Measure-Object | Select -ExpandProperty Count
     
        if($DayStatus -eq 1) { $true} else {$false}
    }
}



Function Get-BusinessHoursElapsed([datetime]$CompareDate, [switch]$ReturnString, [datetime]$EndDate )
{
    # Define when you want to start and end the day using military time
    [datetime]$StartofDay = '8:00:00'
    [datetime]$EndofDay = '17:00:00'
 
    $Now = Get-Date $EndDate
 
    # If the specified date falls within working hours, add up the total amount of time elapsed since the day begin and subtract the time from the end of the day that hasn't elapsed yet
    if((Get-WorkingDays $CompareDate)) { $ElapsedTime = ($EndofDay.TimeOfDay - $CompareDate.TimeOfDay) }
    if((Get-WorkingDays $Now)) { $ElapsedTime = $ElapsedTime + ($Now.TimeOfDay - $StartofDay.TimeOfDay) }
 
    # Get the total number of working days between the specified date and now and add 8 hours for each working day to our total
    $WorkingDays = Get-WorkingDays $CompareDate $Now
    $InBetweenHours = (($WorkingDays) - 1) * 8
    $ElapsedTime = $ElapsedTime.add((New-TimeSpan -Hours $InBetweenHours))
 
 
    # Format the output so that it looks like an elapsed time including leading zeros where required
    if($ReturnString)
    {
        # We want our final output to include only hours.  We do NOT want it to show days if it goes past 24 hours which is the default behavior so we'll convert any days into hours
        $Hours = (($ElapsedTime.Days * 24) + $ElapsedTime.hours)
 
        $Hours = $Hours.tostring("00")
        $Minutes = $($ElapsedTime.Minutes).tostring("00")
        $Seconds = $($ElapsedTime.Seconds).tostring("00")
        $ElapsedTime = "$Hours`:$Minutes`:$Seconds"
         
        return $ElapsedTime
    }
    else
    {
        return $ElapsedTime
    }
     
}
