#region Ensure module meets PowerShell Gallery requirements

## Ensure a manifest exists
$module = Get-Module -Name PSADSyncTool -ListAvailable
$manifestPath = Join-Path -Path $module.ModuleBase -ChildPath "$($module.Name).psd1"
$manifestPath
Test-Path -Path $manifestPath

## Ensure all files referenced exist
Test-ModuleManifest -Path $manifestPath

## Ensure the manifest has all of the required keys
'Description', 'Author', 'Version' | ForEach-Object {
    if (-not $module.$_) {
        Write-Host "$_ key not found!"
    }
}

if (-not $module.PrivateData.PSData.ProjectUri) {
    Write-Host "key not found!"
}

## Add any necessary tags
ise $manifestPath

PrivateData = @{
    PSData = @{
        Tags       = @('PSModule', 'ActiveDirectory')
        ProjectUri = 'https://github.com/adbertram/PSADSyncTool'
    }
}

## Test the required keys again

Import-Module -Name PSADSyncTool -Force
$module = Get-Module -Name PSADSyncTool -ListAvailable

## Run PSScriptAnalyzer
$modulePath = Join-Path -Path $module.ModuleBase -ChildPath "$($module.Name).psm1"
Invoke-ScriptAnalyzer -Path $modulePath -Recurse -Severity Warning

## Fix all warnings. Julia Child'ed it and we already have one
$fixedModulePath = Join-Path -Path $module.ModuleBase -Child 'PSADSyncTool-ScriptAnalyzer-Fixed.psm1'
$modulePath | Remove-Item
Rename-Item -Path $fixedModulePath -NewName 'PSADSyncTool.psm1'

## Run again to ensure everything is fixed
Invoke-ScriptAnalyzer -Path $modulePath -Recurse -Severity Warning

## Ensure the module imports
Import-Module -Name PSADSyncTool -Force

#endregion

#region Update the module version in the manifest
ise $manifestPath
ModuleVersion = '1.1'
#endregion

#region Publish the module

## Prep --ensure you have the latest PowerShellGet and PackageManagement modules
Get-Module -Name PowerShellGet, PackageManagement -List

## Unload any modules in session
Remove-Module -Name PowerShellGet, PackageManagement

## Install the latest version (PowerShellGet upgrades PackageManagement)
Install-Module -Name PowerShellGet

## IMPORTANT: REMOVE OLD VERSION of PackageManagement (if exists)
## Close PowerShell console and remove C:\Program Files\WindowsPowerShell\Modules\PackageManagement\1.0.0.1 folder


## Using key copied from powershellgallery.com
$nuGetKey = 'oy2h6gzx4ucau3dekfpqw5lym7tg657enlhxv7rfokmu6y'

Publish-Module -Name 'PSADSyncTool' -NuGetApiKey $nuGetKey -WhatIf -Verbose

## Publish module for real
Publish-Module -Name 'PSADSyncTool' -NuGetApiKey $nuGetKey

Find-Module -Name 'PSADSyncTool'
#endregion