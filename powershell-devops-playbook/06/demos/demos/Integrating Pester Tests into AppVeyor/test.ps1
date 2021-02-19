## Ensure all errors are terminating errors to catch
$ErrorActionPreference = 'Stop'

try {
	
    ## Ensure we have Pester available
    Import-Module -Name Pester
    $ProjectRoot = $ENV:APPVEYOR_BUILD_FOLDER
	
    ## Path to save all of the Pester test results to
    $testResultsFilePath = "$ProjectRoot\TestResults.xml"
	
    ## Run our set of tests
    $invPesterParams = @{
        Path         = "$ProjectRoot\Tests\Unit.Tests.ps1"
        OutputFormat = 'NUnitXml'
        OutputFile   = $testResultsFilePath
        EnableExit   = $true
    }
    Invoke-Pester @invPesterParams

    ## Upload test results to AppVeyor to review
    $Address = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
    (New-Object 'System.Net.WebClient').UploadFile( $Address, $testResultsFilePath )
	
} catch {
    Write-Error -Message $_.Exception.Message
    $host.SetShouldExit($LastExitCode)
}