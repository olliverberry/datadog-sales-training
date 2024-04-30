param(
    [Parameter(Mandatory=$true)]
    [string] $SubscriptionId
)

function Remove-ResourceGroup ([string] $ResourceGroupId) {
    try {
        $result = Remove-AzResourceGroup -Id $resourceGroup.ResourceId -Force
    }
    catch {
        Write-Host "unable to delete resource group '$($resourceGroup.ResourceGroupName)'. will retry."
        throw
    }
}

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
$rgDeletionJobs = New-Object -TypeName System.Collections.Generic.List[System.Management.Automation.Job]
foreach ($resourceGroup in $resourceGroups) {
    Write-Host "deleting resource group '$($resourceGroup.ResourceGroupName)'."
    $job = Start-Job `
        -ScriptBlock { Remove-ResourceGroup -ResourceGroupId $resourceGroup.ResourceId } `
        -Name $resourceGroup.ResourceId
    $rgDeletionJobs.Add($job)

    Start-Sleep -Seconds 5
}

Write-Host "waiting for '$($rgDeletionJobs.Count)' resource group deletion jobs to complete."
Wait-Job -Job $rgDeletionJobs
$failedJobs = $rgDeletionJobs | Where-Object { $_.State -eq 'Failed' }

if ($failedJobs.Count -eq 0) {
    Write-Host "all resource group deletion jobs completed successfully. exiting."
    exit 0
}

Write-Host "failed to delete '$($failedJobs.Count)' resource groups. will try to delete again."
foreach ($failedJob in $failedJobs) {
    try {
        $result = Remove-AzResourceGroup -Id $failedJob.Name -Force
    }
    catch {
        Write-Host "failed to delete resource group '$($failedJob.Name)'. please delete manually."
    }
}