$ManagementGroupName = "datadog-sales-training"
$managementGroup = Get-AzManagementGroup -GroupName $ManagementGroupName
$subscriptions = Get-AzManagementGroupSubscription -GroupName $managementGroup.Name
foreach ($subscription in $subscriptions) {
    $roleAssignments = Get-AzRoleAssignment -Scope "/subscriptions/$($subscription.Id)"
    foreach ($roleAssignment in $roleAssignments) {
        Remove-AzADUser -ObjectId $roleAssignment.ObjectId
    }
}