#region Create a VM in a lab
$subscriptionId = (Get-AzSubscription -SubscriptionName TechSnips).Id
$vmName = 'TESTVM2'
$vmUserName = 'adam'
$vmPassword = 'I like azure.'

$API_VERSION = '2016-05-15'
$lab = Get-AzResource -ResourceId "/subscriptions/$subscriptionId/resourceGroups/$rgName/providers/Microsoft.DevTestLab/labs/$labName"

$virtualNetwork = @(Get-AzResource -ResourceType 'Microsoft.DevTestLab/labs/virtualnetworks' -ResourceName $labName -ResourceGroupName $lab.ResourceGroupName -ApiVersion $API_VERSION)[0]
$labSubnetName = $virtualNetwork.properties.allowedSubnets[0].labSubnetName

## Figure out what size to use
Get-AzVMSize -Location 'East US'
$size = (Get-AzVMSize -Location 'East US').where({ $_.Name -eq 'Standard_DS2_v2' })

#region Figure out what SKU (OS to use on the VM image)

# Get-AzVMImagePublisher -Location 'East US'
$publisher = (Get-AzVMImagePublisher -Location 'East US').where({ $_.PublisherName -eq 'MicrosoftWindowsServer' })

# Get-AzVMImageOffer -Location 'East US' -PublisherName $publisher.PublisherName
$offer = (Get-AzVMImageOffer -Location 'East US' -PublisherName $publisher.PublisherName).where({ $_.Offer -eq 'WindowsServer' })

# Get-AzVMImageSku -Location 'East US' -PublisherName $publisher.PublisherName -Offer $offer.Offer
$sku = (Get-AzVMImageSku -Location 'East US' -PublisherName $publisher.PublisherName -Offer $offer.Offer).where({ $_.Skus -eq '2019-Datacenter-Core' })

#endregion

#region Build ARM parameters hashtable
$parameters = @{
    "name"       = $vmName
    "location"   = $lab.Location
    "properties" = @{
        "labVirtualNetworkId"   = $virtualNetwork.ResourceId
        "labSubnetName"         = $labSubnetName
        "osType"                = 'Windows'
        "galleryImageReference" = @{
            "offer"     = $sku.Offer
            "publisher" = $sku.PublisherName
            "sku"       = $sku.Skus
            "osType"    = 'Windows'
            "version"   = "latest"
        }
        "size"                  = $size.Name
        "userName"              = $vmUserName
        "password"              = $vmPassword
    }
}
#endregion

## Deploy the VM
Invoke-AzResourceAction -ResourceId $lab.ResourceId -Action 'createEnvironment' -Parameters $parameters -ApiVersion $API_VERSION -Force -Verbose