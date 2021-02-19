## Testing

## Works
PS> Test-AzResourceGroupDeployment -ResourceGroupName 'AdbPluralsightWebAppRG' -TemplateFile 'C:\testarmtemplate.json'

## Edit to make JSON invalid
PS> Test-AzResourceGroupDeployment -ResourceGroupName 'AdbPluralsightWebAppRG' -TemplateFile 'C:\testarmtemplate.json'

## Finding and removing
Get-AzResourceGroupDeployment -ResourceGroupName 'AdbPluralsightWebAppRG'
Get-AzResourceGroupDeployment -ResourceGroupName 'AdbPluralsightWebAppRG' -Name WebAppDeploymen

Get-AzResourceGroupDeployment -ResourceGroupName 'AdbPluralsightWebAppRG' | Remove-AzResourceGroupDeployment