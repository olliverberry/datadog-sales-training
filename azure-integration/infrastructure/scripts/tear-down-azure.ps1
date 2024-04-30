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
$resourceGroups = Get-AzResourceGroup -Tag @{ company="datadog" }
Write-Host "deleting '$($resourceGroups.Count)' resource groups."
$deletionJobs = New-Object -TypeName 'System.Collections.Generic.List[Microsoft.Azure.Commands.Common.AzureLongRunningJob]'
foreach ($resourceGroup in $resourceGroups) {
    Write-Host "deleting resource group '$($resourceGroup.ResourceGroupName)'."
    $job = Remove-AzResourceGroup -ResourceGroupId $resourceGroup.ResourceId -Force -AsJob
    $deletionJobs.Add($job)
    Start-Sleep -Seconds 5
}

$jobTimeout = 180
Write-Host "waiting for '$($deletionJobs.Count)' resource group deletion jobs to complete. will wait for '$jobTimeout' seconds."
Wait-Job -Job $deletionJobs -Timeout $jobTimeout

$provisioningState = "deleting"
Write-Host "searching for resource groups that are not in the 'deleting' state."
$resourceGroups = Get-AzResourceGroup `
    -Tag @{ company="datadog" } `
    | Where-Object { $_.ProvisioningState -ne 'deleting' }
if (-not $resourceGroups) {
    "all resource groups are in a 'deleting' state. exiting."
}

Write-Host "trying to delete resource groups `
    '$($resourceGroups | Join-String -Property ResourceGroupName -Separator ', ')' again.`
    please check that they are deleted as this is the last attempt."
foreach ($resourceGroup in $resourceGroups) {
    $job = Remove-AzResourceGroup -Id $resourceGroup.ResourceId -Force -AsJob
    Start-Sleep -Seconds 5
}