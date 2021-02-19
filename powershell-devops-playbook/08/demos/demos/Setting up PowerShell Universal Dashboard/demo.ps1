## Cover all steps one by one to deploy UD to Azure

$WebAppName = 'ADBPoshUD-Test'
$AzureLocation = 'East US'
$AzureResourceGroup = 'Course-PowerShellDevOpsPlaybook'

#region Create the Azure web app
$appSrvPlan = New-AzAppServicePlan -Name "$WebAppName-AppSrv" -Location $AzureLocation -ResourceGroupName $AzureResourceGroup -Tier Free
$null = New-AzWebApp -Name $WebAppName -AppServicePlan $appSrvPlan.Name -ResourceGroupName $AzureResourceGroup -Location $AzureLocation
#endregion

#region Download UD
Save-Module UniversalDashboard.Community -Path $env:TEMP -AcceptLicense
$udModulePath = (Get-ChildItem -Path "$env:TEMP\UniversalDashboard.Community" -Directory).FullName
#endregion

# Get publishing profile for the web app
$pubProfile = Get-AzWebAppPublishingProfile -Name $Webappname -ResourceGroupName $AzureResourceGroup
$ftpPubProfile = ([xml]$pubProfile).publishData.publishProfile | Where-Object { $_.publishMethod -eq 'FTP' }

## Build the cred to authenticate
$password = ConvertTo-SecureString $ftpPubProfile.userPWD -AsPlainText -Force
$azureCred = New-Object System.Management.Automation.PSCredential ($ftpPubProfile.userName, $password)

$webclient = New-Object -TypeName System.Net.WebClient
$webclient.Credentials = $azureCred

#region Create all folders
Get-ChildItem -Path $udModulePath -Directory -Recurse | foreach {
    $path = $_.FullName.Replace("$udModulePath\", '').Replace('\', '/')
    $uri = "$($ftpPubProfile.publishUrl)/$path"
    $makeDirectory = [System.Net.WebRequest]::Create($uri)
    $makeDirectory.Credentials = $azureCred
    $makeDirectory.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory
    Write-Host "Creating folder [$path]..."
    $null = $makeDirectory.GetResponse()
}
#endregion

## Create a simple dashboard to bring the site up
Set-Content -Path "$udModulePath\dashboard.ps1" -Value 'Start-UDDashboard -Wait'

#region Upload all of the files
Get-ChildItem -Path $udModulePath -File -Recurse | foreach {
    $path = $_.FullName.Replace("$udModulePath\", '').Replace('\', '/').Replace('.\', '')
    $uri = New-Object System.Uri("$($ftpPubProfile.publishUrl)/$path")
    Write-Host "Uploading file [$path]..."
    $null = $webclient.UploadFile($uri, $_.FullName)
}
#endregion
$webclient.Dispose()

## Wrap all steps covered into a single script

param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$WebAppName,
	
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$AzureLocation,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$AzureResourceGroup
)

#region Create the Azure web app
$appSrvPlan = New-AzAppServicePlan -Name "$WebAppName-AppSrv" -Location $AzureLocation -ResourceGroupName $AzureResourceGroup -Tier Free
$null = New-AzWebApp -Name $WebAppName -AppServicePlan $appSrvPlan.Name -ResourceGroupName $AzureResourceGroup -Location $AzureLocation
#endregion

#region Download UD
Save-Module UniversalDashboard.Community -Path $env:TEMP -AcceptLicense
$udModulePath = (Get-ChildItem -Path "$env:TEMP\UniversalDashboard.Community" -Directory).FullName
#endregion

# Get publishing profile for the web app
$pubProfile = Get-AzWebAppPublishingProfile -Name $Webappname -ResourceGroupName $AzureResourceGroup
$ftpPubProfile = ([xml]$pubProfile).publishData.publishProfile | Where-Object { $_.publishMethod -eq 'FTP' }

## Build the cred to authenticate
$password = ConvertTo-SecureString $ftpPubProfile.userPWD -AsPlainText -Force
$azureCred = New-Object System.Management.Automation.PSCredential ($ftpPubProfile.userName, $password)

try {
    $webclient = New-Object -TypeName System.Net.WebClient
    $webclient.Credentials = $azureCred

    #region Create all folders
    Get-ChildItem -Path $udModulePath -Directory -Recurse | foreach {
        $path = $_.FullName.Replace("$udModulePath\", '').Replace('\', '/')
        $uri = "$($ftpPubProfile.publishUrl)/$path"
        $makeDirectory = [System.Net.WebRequest]::Create($uri)
        $makeDirectory.Credentials = $azureCred
        $makeDirectory.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory
        Write-Host "Creating folder [$path]..."
        $null = $makeDirectory.GetResponse()
    }
    #endregion

    ## Create a simple dashboard to bring the site up
    Set-Content -Path "$udModulePath\dashboard.ps1" -Value 'Start-UDDashboard -Wait'

    #region Upload all of the files
    Get-ChildItem -Path $udModulePath -File -Recurse | foreach {
        $path = $_.FullName.Replace("$udModulePath\", '').Replace('\', '/').Replace('.\', '')
        $uri = New-Object System.Uri("$($ftpPubProfile.publishUrl)/$path")
        Write-Host "Uploading file [$path]..."
        $null = $webclient.UploadFile($uri, $_.FullName)
    }
    #endregion
} catch {
    $PSCmdlet.ThrowTerminatingError($_)
} finally {
    ## Cleanup
    $webclient.Dispose()
}

PS> C:\New-UDAzureInstance.ps1 -WebAppName ADBPoshUD -AzureResourceGroup 'Course-PowerShellDevOpsPlaybook' -AzureLocation 'East US'