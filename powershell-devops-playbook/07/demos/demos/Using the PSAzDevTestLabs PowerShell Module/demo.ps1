#region Building DevTest Labs resources with a custom PowerShell tool

## Available on GitHub: https://github.com/adbertram/PSAzDevTestLabs

Install-Module PSAzDevTestLabs

Import-Module PsAzDevTestLabs
Get-Command -Module PSAzDevTestLabs

## define common variables
$subscriptionId = (Get-AzSubscription -SubscriptionName 'TechSnips').Id
$rgName = 'Course-PowerShellDevOpsPlaybook'
$labName = 'TestLab'
$vmName = 'TESTVM'

## Build the lab
New-AzDevTestLab -SubscriptionId $subscriptionId -ResourceGroupName $rgName -Name $labName -VirtualNetworkName TestLabvNet

## Build the VM
$publisher = (Get-AzVMImagePublisher -Location 'East US').where({ $_.PublisherName -eq 'MicrosoftWindowsServer' })
$offer = (Get-AzVMImageOffer -Location 'East US' -PublisherName $publisher.PublisherName).where({ $_.Offer -eq 'WindowsServer' })
$sku = (Get-AzVMImageSku -Location 'East US' -PublisherName $publisher.PublisherName -Offer $offer.Offer).where({ $_.Skus -eq '2019-Datacenter-Core' })
$size = (Get-AzVMSize -Location 'East US').where({ $_.Name -eq 'Standard_DS2_v2' })

$newVmParams = @{
    Name              = $vmName
    SubscriptionId    = $subscriptionId
    ResourceGroupName = $rgName
    LabName           = $labName
    AdminUserName     = 'adam'
    AdminPassword     = 'I like Azure.'
    VMImageOffer      = $sku.Offer
    VMImagePublisher  = $sku.PublisherName
    VMImageSku        = $sku.Skus
    VmSize            = $size.Name
}
New-AzDevTestLabVM @newVmParams

## Add some artifacts and use Chocolatey to install some packages
$source = Get-AzDevTestLabArtifactSource -LabName $labName -ResourceGroupName $rgName
$installParams = @{
    Name              = 'windows-chocolatey'
    VmName            = $vmName
    LabName           = $labName
    SourceName        = $source.Name
    SubscriptionId    = $subscriptionId
    ResourceGroupName = $rgName
    Parameters        = @{
        'name'  = 'packages'
        'value' = 'vcredist140,python2'
    }
}
Install-AzDevTestLabArtifact @installParams

## Add a user
New-AzDevTestLabUser -DisplayName 'Adam Bertram' -LabName $labName -ResourceGroupName $rgName -SubscriptionId $subscriptionId

## Clean up the lab
Remove-AzDevTestLab -Name $labName -SubscriptionId $subscriptionId -ResourceGroupName $rgName -Force -Verbose

#endregion