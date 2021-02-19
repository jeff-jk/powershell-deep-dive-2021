## Create the resource group

$location = 'East US'
$rgName = 'AdbPluralsightWebAppRG'

if (-not ($rg = Get-AzResourceGroup -Name $rgName -ErrorAction Ignore)) {
    $rg = New-AzResourceGroup -Name $rgName -Location $location
}

## Create the web app

$appServicePlanName = 'AdbPluralsightWebApp'
if (-not ($appSrvPlan = Get-AzAppServicePlan -ResourceGroupName $rgName -Name $appServicePlanName -ErrorAction Ignore)) {
    $appSrvPlan = New-AzAppServicePlan -Name $appServicePlanName -Location $location -ResourceGroupName $rgName -Tier 'Free'
}

$webAppName = 'AdbPluralsightWebApp'
if (-not ($webApp = Get-AzWebApp -ResourceGroupName $rgName -Name $webAppName -ErrorAction Ignore)) {
    $webapp = New-AzWebApp -Name $webAppName -AppServicePlan $appSrvPlan.Name -ResourceGroupName $rgName -Location $location
}

## Provision the SQL database

$securePassword = ConvertTo-SecureString 'S3cret!Password' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ('sqladmin', $securepassword)

$sqlSrvParams = @{
    'ResourceGroupName'           = $rgName
    'ServerName'                  = 'adbpluralsightsqlsrv'
    'Location'                    = $location
    'SqlAdministratorCredentials' = $cred
}
if (-not ($sqlServer = Get-AzSqlServer -ServerName $sqlSrvParams.ServerName -ErrorAction Ignore)) {
    $sqlServer = New-AzSqlServer @sqlSrvParams
}

$fwRuleParams = @{
    'ResourceGroupName' = $rgName
    'ServerName'        = $sqlServer.ServerName
    'FirewallRuleName'  = 'AllowAllWindowsAzureIps'
    'StartIpAddress'    = '0.0.0.0'
    'EndIpAddress'      = '0.0.0.0'
}
if (-not ($serverFirewallRule = Get-AzSqlServerFirewallRule -ResourceGroupName $rgName -ServerName $fwRuleParams.ServerName -Name $fwRuleParams.FirewallRuleName -ErrorAction Ignore)) {
    $serverFirewallRule = New-AzSqlServerFirewallRule @fwRuleParams
}

$sqlDbParams = @{
    'ResourceGroupName' = $rgName
    'ServerName'        = $sqlServer.ServerName
    'DatabaseName'      = 'webappdb'
}
if (-not ($sqlDatabase = Get-AzSqlDatabase -ResourceGroupName $rgName -ServerName $sqlSrvParams.ServerName -Name $sqlDbParams.DatabaseName -ErrorAction Ignore)) {
    $sqlDatabase = New-AzSqlDatabase @sqlDbParams
}