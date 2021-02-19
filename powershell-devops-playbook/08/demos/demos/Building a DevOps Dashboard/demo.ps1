## demo

#region Figure out how to design and build the dashboard

<# 1. Design the dashboard how you'd like it to be
	- dropdown to select AppVeyor project
	- grid to display the last 10 builds for the project in the dropdown
		- columns
			- version
			- committer
			- status
			- time started
			- time finished
	- ability to view the individual build logs for each build in the grid. button?
#>

# 2. Figure out how to pull data you want to display

## AppVeyor API docs: https://www.appveyor.com/docs/api/
	
## Find project names for the dropdown
$authHeaders = @{
    "Authorization" = 'Bearer XXXXXXXX'
    "Content-type"  = "application/json"
}
$projects = Invoke-RestMethod -Method Get -Uri 'https://ci.appveyor.com/api/projects' -Headers $authHeaders
$projects.name | Sort-Object -Property Name

## Find the build history for a single project (for the grid)
$buildHistory = Invoke-RestMethod -Method Get -Uri 'https://ci.appveyor.com/api/projects/adbertram/psadsync/history?recordsNumber=10' -Headers $authHeaders
$buildHistory
$buildHistory.builds
$buildHistory.builds[0]

## Find a single build
$testProject = $projects | Where-Object Name -eq 'PSADSync'
$testProject.slug
$buildVer = $buildHistory.builds[0].version
$build = Invoke-RestMethod -Method Get -Uri "https://ci.appveyor.com/api/projects/adbertram/psadsync/build/$buildVer" -Headers $authHeaders

## Find the build log (for the button on the grid)
$jobId = $result.build.jobs.jobid
Invoke-RestMethod -Method Get -Uri "https://ci.appveyor.com/api/buildjobs/$jobId/log" -Headers $authHeaders

# 3. Build the dashboard
ise C:\dashboard.ps1

#endregion

#region Deploy dashboard to Azure app service

## Upload the dashboard
$localDashboardPath = 'C:\dashboard.ps1'

$pubProfile = Get-AzWebAppPublishingProfile -Name 'ADBPoshUD' -ResourceGroupName 'Course-PowerShellDevOpsPlaybook'
$ftpPubProfile = ([xml]$pubProfile).publishData.publishProfile | Where-Object { $_.publishMethod -eq 'FTP' }

$uri = New-Object System.Uri("$($ftpPubProfile.publishUrl)/dashboard.ps1")
$null = $webclient.UploadFile($uri, $localDashboardPath)
$webclient.Dispose()

## Restart the app service
$webApp = Get-AzWebApp -ResourceGroupName 'Coruse-PowerShellDevOpsPlaybook' -Name 'ADBPoshUD'
$webApp | Restart-AzWebApp

## Bask in the beauty of the dashboard
Invoke-Item $webApp.HostNames

#endregion