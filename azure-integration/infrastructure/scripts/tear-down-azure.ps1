param(
    [Parameter(Mandatory=$true)]
    [string] $SubscriptionId
)

Write-Host "getting subscription '$SubscriptionId'."
$subscription = Get-AzSubscription -SubscriptionId $SubscriptionId -ErrorAction SilentlyContinue
if (-not $subscription) {
    Write-Host "unable to find subscription '$SubscriptionId'. exiting."
    exit 0
}

Write-Host "getting role assignments for subscription '$($subscription.Id)'."
$roleAssignments = Get-AzRoleAssignment -Scope $subscription.Id
foreach ($roleAssignment in $roleAssignments) {
    if ($roleAssignment.SignInName -like "*user*" -and $roleAssignment.ObjectType -eq "User") {
        Write-Host "removing user '$($roleAssignment.SignInName)'"
        Remove-AzADUser -ObjectId $roleAssignment.ObjectId
        Start-Sleep -Seconds 15
    }
}

Set-AzContext -Subscription $subscription.Id
$resourceGroups = Get-AzResourceGroup
foreach ($resourceGroup in $resourceGroups) {
    Remove-AzResourceGroup -Id $resourceGroup.ResourceId -Force
    Start-Sleep -Seconds 15
}