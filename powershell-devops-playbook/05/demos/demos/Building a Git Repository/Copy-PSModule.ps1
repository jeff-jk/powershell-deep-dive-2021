param($ModuleName)

$modulesBasePath = '\\10.0.0.5\PowerShellModules'

$remoteModulePath = Join-Path -Path $modulesBasePath -ChildPath $ModuleName
$localModulePath = 'C:\Program Files\WindowsPowerShell\Modules\'

Copy-Item -Path $remoteModulePath -Destination $localModulePath -Recurse -Force
Import-Module $ModuleName