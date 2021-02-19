## dashboard.ps1

#region Auth/variable setup
$apiUrl = 'https://ci.appveyor.com/api'
$authToken = 'u26g8a7ixa0qs9usjosb'
$authHeaders = @{
    "Authorization" = "Bearer $authToken"
    "Content-type"  = "application/json"
}
$accountName = 'adbertram'
$baseProjectUri = "$apiUrl/projects/$accountName"
#endregion

$gridContent = {

    # Read the currently selected value of the selected project drop down
    $SelectedProject = (Get-UDElement -Id 'selectedProject').Attributes
    if (-not $SelectedProject) {
        $SelectedProject = 'psazdevtestlabs'
    } else {
        $SelectedProject = $SelectedProject['value'].ToLower()
    }

    $projectUri = "$baseProjectUri/$SelectedProject"
	
    ## Get previous project build statuses
    $buildHistoryUri = "$projectUri/history?recordsNumber=10"
    $result = Invoke-RestMethod -Method Get -Uri $buildHistoryUri -Headers $authHeaders

    $selectProperties = @(
        'version'
        'committerName'
        'status'
        'started'
        'finished'
        @{Name = 'Build Log'; Expression = {
                New-UDButton -Text 'View Build Log' -OnClick (New-UDEndpoint -Endpoint { 
                        Show-UDModal -Header { New-UDHeading -Size 4 -Text "Build Log" } -Content {
                            $buildVer = $ArgumentList[0]
                            $projectslug = $ArgumentList[1]
                            $projectUri = "https://ci.appveyor.com/api/projects/adbertram/$projectSlug"
                            $buildUri = "$projectUri/build/$buildVer"
                            $result = Invoke-RestMethod -Method Get -Uri $builduri -Headers $authHeaders
									
                            $jobId = $result.build.jobs.jobid
                            $buildLoguri = "$apiUrl/buildjobs/$jobId/log"
                            $log = Invoke-RestMethod -Method Get -Uri $buildLoguri -Headers $authHeaders
                            New-UDCard -Text $log
                        }
                    } -ArgumentList $_.version, $SelectedProject)
            }
        }
    )
	
    $result.builds | Select-Object -First 10 -Property $selectProperties | Out-UDGridData
}

$props = @('version',
    'committerName',
    'status',
    'started',
    'finished',
    'Build Log'
)
$content = {
    # Get the projects and create a select with options for each project. 
    # Make sure to include -OnChange to work around a bug in 2.4 (fixed in 2.5)
    $listProjectsUri = "$apiUrl/projects"
    $projects = Invoke-RestMethod -Method Get -Uri $listProjectsUri -Headers $authHeaders
    New-UDSelect -Id selectedProject -Option {
        $projects | Sort Name | ForEach-Object { 
            New-UDSelectOption -Name $_.Name -Value $_.Name
        }
    } -OnChange { Sync-UDElement -Id 'grid' } -Label Projects

    New-UDGrid -Title "Build History" -Headers $props -Properties $props -Endpoint $gridContent -Id 'grid'
}
$Dashboard = New-UDDashboard -Title "DevOps Dashboard" -Content $content
Start-UDDashboard -Dashboard $Dashboard -Wait