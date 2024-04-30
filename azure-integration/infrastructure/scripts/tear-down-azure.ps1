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
$deletionJobs = New-Object -TypeName 'System.Collections.Generic.List[Microsoft.Azure.Commands.Common.AzureLongRunningJob]'
foreach ($resourceGroup in $resourceGroups) {
    Write-Host "deleting resource group '$($resourceGroup.ResourceGroupName)'."
    $job = Remove-AzResourceGroup -ResourceGroupId $resourceGroup.ResourceId -Force -AsJob
    $deletionJobs.Add($job)

    Start-Sleep -Seconds 5
}

Write-Host "waiting for '$($deletionJobs.Count)' resource group deletion jobs to complete."
Wait-Job -Job $deletionJobs
$failedJobs = $deletionJobs | Where-Object { $_.State -eq 'Failed' }
if ($failedJobs.Count -eq 0) {
    Write-Host "all resource group deletion jobs completed successfully. exiting."
    exit 0
}

Write-Host "failed to delete '$($failedJobs.Count)' resource groups. will try to delete again."
$deletionJobs.Clear()
$resourceGroups = Get-AzResourceGroup | Where-Object { $_.ProvisioningState -ne 'deleting' }
Write-Host "trying to delete resource groups `
    '$($resourceGroups | Join-String -Property ResourceGroupName -Separator ', ')' again.`
    please check that they are deleted."
foreach ($resourceGroup in $resourceGroups) {
    $job = Remove-AzResourceGroup -Id $resourceGroup.ResourceId -Force -AsJob
    $deletionJobs.Add($job)

    Start-Sleep -Seconds 5
}