#region Building DevTest Labs resources with PowerShell the hard way

$labName = 'TestLab'
$rgName = 'Course-PowerShellDevOpsPlaybook'
$vNetName = 'TestNetwork'

#region Build a lab
$labArm = @{
    '$schema'        = "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#"
    "contentVersion" = "1.0.0.0"
    "resources"      = @(
        @{
            "apiVersion" = "2018-10-15-preview"
            "type"       = "Microsoft.DevTestLab/labs"
            "name"       = "$labName"
            "location"   = "[resourceGroup().location]"
            "resources"  = @(
                @{
                    "apiVersion" = "2018-10-15-preview"
                    "name"       = $vNetName
                    "type"       = "virtualNetworks"
                    "dependsOn"  = @(
                        "[resourceId('Microsoft.DevTestLab/labs','$labName')]"
                    )
                }
            )
        }
    )
    "outputs"        = @{
        "labId" = @{
            "type"  = "string"
            "value" = "[resourceId('Microsoft.DevTestLab/labs','$labName')]"
        }
    }
}

New-AzResourceGroupDeployment -Name 'devtestlabtest' -ResourceGroupName $rgName -TemplateObject $labArm -Verbose

#endregion