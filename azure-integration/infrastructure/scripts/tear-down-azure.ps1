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
$roleAssignments = Get-AzRoleAssignment -Scope "/subscriptions/$($subscription.Id)"
foreach ($roleAssignment in $roleAssignments) {
    if ($roleAssignment.SignInName -like "*user*" -and $roleAssignment.ObjectType -eq "User") {
        Write-Host "removing user '$($roleAssignment.SignInName)'"
        $removeUser = Remove-AzADUser -ObjectId $roleAssignment.ObjectId
        Start-Sleep -Seconds 5
    }
}

$azContext = Set-AzContext -Subscription $subscription.Id
$resourceGroups = Get-AzResourceGroup
Write-Host "deleting resource group deployments and resource groups."
$failedDeletionRgs = New-Object -TypeName System.Collections.Generic.List[string]
foreach ($resourceGroup in $resourceGroups) {
    $deployments = Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroup.ResourceGroupName
    foreach ($deployment in $deployments) {
        Write-Host "deleting resource group deployment '$($deployment.DeploymentName)' for resource group '$($resourceGroup.ResourceGroupName)'."
        $result = Remove-AzResourceGroupDeployment `
            -ResourceGroupName $resourceGroup.ResourceGroupName `
            -Name $deployment.DeploymentName `
            -ErrorAction Continue
    }

    Write-Host "deleting resource group '$($resourceGroup.ResourceGroupName)'."
    try {
        $result = Remove-AzResourceGroup -Id $resourceGroup.ResourceId -Force
    }
    catch {
        Write-Host "unable to delete resource group '$($resourceGroup.ResourceGroupName)'. will retry."
        $failedDeletionRgs.Add($resourceGroup.ResourceId)
    }

    Start-Sleep -Seconds 5
}

if ($failedDeletionRgs.Count -gt 0) {
    Write-Host "failed to delete '$($failedDeletionRgs.Count)' resource groups. will try to delete again."
    foreach ($resourceGroup in $resourceGroups) {
        $result = Remove-AzResourceGroup -Id $resourceGroup.ResourceId -Force
        Start-Sleep -Seconds 5
    }
}