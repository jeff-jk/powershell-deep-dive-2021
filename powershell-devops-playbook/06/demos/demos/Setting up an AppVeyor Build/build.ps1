## Ensure all errors are terminating errors to catch
$ErrorActionPreference = 'Stop'

try {
	
    #region Read the module manifest
    $manifestFilePath = "$env:APPVEYOR_BUILD_FOLDER\PSAdSyncTool.psd1"
    $manifestContent = Get-Content -Path $manifestFilePath -Raw
    #endregion

    #region Update the module version based on the build version and limit exported functions
    ## Use the AppVeyor build version as the module version
    $replacements = @{
        "ModuleVersion = '.*'" = "ModuleVersion = '$env:APPVEYOR_BUILD_VERSION'"
    }		

    $replacements.GetEnumerator() | foreach {
        $manifestContent = $manifestContent -replace $_.Key, $_.Value
    }

    $manifestContent | Set-Content -Path $manifestFilePath
    #endregion

} catch {
    Write-Error -Message $_.Exception.Message
    ## Ensure the build knows to fail
    $host.SetShouldExit($LastExitCode)
}