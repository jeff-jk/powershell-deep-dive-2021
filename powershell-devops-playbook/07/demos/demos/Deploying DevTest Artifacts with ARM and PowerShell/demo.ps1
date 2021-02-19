#region Add an artifact to a VM
$artifactRepoName = 'Public Repo'

## Could use artifacts to deploy software but Chocolatey has a lot more options. Just install Chocolatey and use it for package management.
$artifactName = 'windows-chocolatey'

# Get the internal repo name
$getRepoParams = @{
    ResourceGroupName = $rgName
    ResourceType      = 'Microsoft.DevTestLab/labs/artifactsources'
    ResourceName      = $labName
    ApiVersion        = $API_VERSION

}
$repository = Get-AzResource @getRepoParams | Where-Object { $_.Name -eq $artifactRepoName } 

# Get the internal artifact name
$getArtParams = @{
    ResourceGroupName = $rgName
    ResourceType      = 'Microsoft.DevTestLab/labs/artifactSources/artifacts'
    ResourceName      = "$labName/$($repository.Name)"
    ApiVersion        = $API_VERSION
}
$artifact = Get-AzResource @getArtParams | Where-Object { $_.Name -eq $artifactName }

# Find the virtual machine in Azure
$vMId = "/subscriptions/$subscriptionId/resourceGroups/$rgName/providers/Microsoft.DevTestLab/labs/$labName/virtualmachines/$vmName"
$vm = Get-AzResource -ResourceId $vMId

# Generate the artifact id
$artifactId = "/subscriptions/$subscriptionId/resourceGroups/$rgName/providers/Microsoft.DevTestLab/labs/$labName/artifactSources/$($repository.Name)/artifacts/$($artifact.Name)"

## Find available chocolatey packages
Get-ChocolateyPackage

## Deploy Chocolatey artifact and install choco packages at the same time
$artifactParameters = @(
    @{
        'name'  = 'packages'
        'value' = 'vcredist140,python2'
    }
)

$prop = @{
    artifacts = @(
        @{
            artifactId = $artifactId
            parameters = $artifactParameters
        }
    )
}

# Apply the artifact by name to the virtual machine
Invoke-AzResourceAction -Parameters $prop -ResourceId $vm.ResourceId -Action "applyArtifacts" -ApiVersion $API_VERSION -Force

#endregion