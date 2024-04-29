$ManagementGroupName = "datadog-sales-training"
$managementGroup = Get-AzManagementGroup -GroupName $ManagementGroupName -ErrorAction SilentlyContinue
if (-not $managementGroup) {
    Write-Host "unable to find management group '$ManagementGroupName'. exiting."
    exit 0
}

Write-Host "getting subscriptions for management group '$($managementGroup.Name)'."
$subscriptions = Get-AzManagementGroupSubscription -GroupName $managementGroup.Name
Write-Host "got '$($subscriptions.Count)' subscriptions."
if ($subscriptions.Count -eq 0) {
    exit 0
}

foreach ($subscription in $subscriptions) {
    Write-Host "getting role assignments for subscription '$($subscription.Id)'."
    $roleAssignments = Get-AzRoleAssignment -Scope $subscription.Id
    foreach ($roleAssignment in $roleAssignments) {
        if ($roleAssignment.SignInName -like "*user*" -and $roleAssignment.ObjectType -eq "User") {
            Write-Host "removing user '$($roleAssignment.SignInName)'"
            Remove-AzADUser -ObjectId $roleAssignment.ObjectId
            Start-Sleep -Seconds 15
        }
    }

    Set-AzContext -SubscriptionObject $subscription
    $resourceGroups = Get-AzResourceGroup
    foreach ($resourceGroup in $resourceGroups) {
        Remove-AzResourceGroup -Id $resourceGroup.ResourceId -Force
        Start-Sleep -Seconds 15
    }
}