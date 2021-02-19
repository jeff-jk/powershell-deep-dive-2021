C:\Copy-PSModule.ps1 -ModuleName PSADSyncTool
Get-Module -Name PSADSyncTool -List
ise *\\10.0.0.5\PowerShellModules\PSADSyncTool\PSADSync.psm1*
C:\Copy-PSModule.ps1 -ModuleName PSADSyncTool
Import-Module -Name PSADSyncTool -Force
copy \\10.0.0.5\PowerShellModules\PSADSyncTool\* c:\users\adam\documents\github\PSADSyncTool -Recurse
copy c:\users\adam\documents\github\PSADSyncTool\* 'C:\Program Files\WindowsPowerShell\Modules\PSADSyncTool' -Recurse -Force
Import-Module -Name PSADSyncTool -Force
$git = 'C:\users\adam\AppData\Local\GitHubDesktop\app-2.0.4\resources\app\git\cmd\git.exe'
cd C:\users\adam\Documents\GitHub\PSADSyncTool\
& $git log
& $git reset HEAD^ --hard