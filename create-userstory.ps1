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

# To create Work Item using this function
create-userStory -org "rubix-group" -project test-destination -Description "test Description" -TitleValue "new title for testing from PS" -SourceProject "test-source"


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