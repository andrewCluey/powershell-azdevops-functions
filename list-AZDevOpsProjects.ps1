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