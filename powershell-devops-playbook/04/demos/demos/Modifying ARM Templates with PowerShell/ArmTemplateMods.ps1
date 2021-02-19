function New-AzArmTemplateResource {
    [OutputType('pscustomobject')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Json
    )

    $Json | ConvertFrom-Json
}

function Set-AzArmTemplate {
    [OutputType('void')]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TemplatePath,

        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [pscustomobject]$Resource
    )

    ## Read the template and convert to an object
    $armTemplate = Get-Content -Path $TemplatePath -Raw | ConvertFrom-Json
	
    ## Append the resource object to the end of the resource section
    $armTemplate.resources += $Resource

    ## Remove escaped unicode characters
    $template = $armTemplate | ConvertTo-Json -Depth 100 | foreach { [System.Text.RegularExpressions.Regex]::Unescape($_) }

    ## Commit to disk
    $template | Set-Content -Path $TemplatePath
}