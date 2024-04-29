param (
    [Parameter(Mandatory=$true)]
    [int] $NumberOfUsers,

    [Parameter(Mandatory=$true)]
    [string] $SubscriptionId,

    [Parameter(Mandatory=$true)]
    [securestring] $Password,

    [Parameter(Mandatory=$true)]
    [string] $DomainName,

    [Parameter(Mandatory=$true)]
    [string] $OwnerId,
    
    [Parameter(Mandatory=$false)]
    [string] $ResourceGroupPrefix = "datadog-sales-training"
)

$subscription = Get-AzSubscription -SubscriptionId $SubscriptionId
if (-not $subscription) {
    Write-Host "unable to find subscription '$($SubscriptionId)'. please ensure that it exists."
    exit 1
}

$ManagementGroupName = "datadog-sales-training"
$managementGroup = Get-AzManagementGroup -GroupName $ManagementGroupName -ErrorAction SilentlyContinue
if (-not $managementGroup) {
    Write-Host "management group '$ManagementGroupName' does not exist. creating..."
    $managementGroup = New-AzManagementGroup -GroupName $ManagementGroupName -DisplayName 'Datadog Sales Training'
}


$ownerRole = Get-AzRoleDefinition -Name "Owner"
$assignedRoles = Get-AzRoleAssignment -Scope $managementGroup.Id
$ownerAssignedRole = $assignedRoles | Where-Object { $_.ObjectId -eq $OwnerId }
if (-not $ownerAssignedRole) {
    Write-Host "unable to find owner assigned role for management group. will assign."
    New-AzRoleAssignment -ObjectId $OwnerId `
        -RoleDefinitionId $ownerRole.Id `
        -Scope $managementGroup.Id
}

$groupSubscription = Get-AzManagementGroupSubscription -GroupName $managementGroup.Name -SubscriptionId $subscription.Id -ErrorAction SilentlyContinue
if (-not $groupSubscription) {
    Write-Host "management group '$($managementGroup.DisplayName)' does not have subscription '$($SubscriptionId)'. moving it."
    New-AzManagementGroupSubscription -GroupName $managementGroup.Name -SubscriptionId $subscription.Id
}

$createdRgs = New-Object -TypeName System.Collections.Generic.List[string]
$context = Set-AzContext -SubscriptionObject (Get-AzSubscription -SubscriptionId $subscription.Id)
for ($i = 1; $i -le $NumberOfUsers; $i++) { 
    $user = "user$i"
    $upn = "$user@$DomainName"
    $newUser = New-AzADUser -DisplayName $user `
        -Password $Password `
        -AccountEnabled $true `
        -MailNickname $user `
        -UserPrincipalName $upn
    
    Write-Host "created user '$($newUser.DisplayName)'."
    Start-Sleep -Seconds 15

    $resourceGroup = New-AzResourceGroup -Name "$ResourceGroupPrefix-$user-rg" -Location "Central US"
    $createdRgs.Add($resourceGroup.ResourceId)
    New-AzRoleAssignment -SignInName $newUser.UserPrincipalName `
        -RoleDefinitionName $ownerRole.Name `
        -Scope $resourceGroup.ResourceId
    Start-Sleep -Seconds 15
}

$createdRgs | Join-String -Separator ', '
return $createdRgs