$ManagementGroupName = "datadog-sales-training"
$managementGroup = Get-AzManagementGroup -GroupName $ManagementGroupName
$subscriptions = Get-AzManagementGroupSubscription -GroupName $managementGroup.Name
Write-Host "Got '$($subscriptions.Count)' subscriptions."
if ($subscriptions.Count -eq 0) {
    exit 0
}

foreach ($subscription in $subscriptions) {
    $roleAssignments = Get-AzRoleAssignment -Scope "/subscriptions/$($subscription.Id)"
    foreach ($roleAssignment in $roleAssignments) {
        Remove-AzADUser -ObjectId $roleAssignment.ObjectId
        Start-Sleep -Seconds 15
    }
}