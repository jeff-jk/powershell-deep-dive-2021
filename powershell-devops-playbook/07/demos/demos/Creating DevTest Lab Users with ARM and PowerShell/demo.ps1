#region Add a DevTest user
# Values to change
$DisplayName = "Adam Bertram"

# Retrieve the user object
$adObject = Get-AzADUser -DisplayName $DisplayName

# Create the role assignment. 
$labId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.DevTestLab/labs/$labName"
New-AzRoleAssignment -ObjectId $adObject.Id -RoleDefinitionName 'DevTest Labs User' -Scope $labId
#endregion