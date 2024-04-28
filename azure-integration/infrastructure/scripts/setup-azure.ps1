param (
    [Parameter(Mandatory=$true)]
    [int] $NumberOfUsers,

    [Parameter(Mandatory=$true)]
    [string] $BillingString,

    [Parameter(Mandatory=$true)]
    [securestring] $Password,

    [Parameter(Mandatory=$true)]
    [string] $DomainName,

    [Parameter(Mandatory=$true)]
    [string] $OwnerId
)

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
    New-AzRoleAssignment -ObjectId $OwnderId `
        -RoleDefinitionId $ownerRole.Id `
        -Scope $managementGroup.Id
}

$subscriptions = Get-AzManagementGroupSubscription -GroupName $managementGroup.Name
if ($subscriptions.Count -lt $NumberOfUsers) {
    Write-Host "installing 'Az.Subscription' module."
    Install-Module -Name "Az.Subscription" -MinimumVersion "0.9.0" -Scope CurrentUser -Force

    Write-Host "missing subscriptions. will create '$($NumberOfUsers - $subscriptions.Count)' new subscriptions."
    for ($i = $subscriptions.Count + 1; $i -le $NumberOfUsers; $i++) {
        $newSubscription = New-AzSubscriptionAlias -AliasName "user$i-subscription" `
            -SubscriptionName "User$i Subscription" `
            -BillingScope $BillingString `
            -Workload "Production" `
            -ManagementGroupId $managementGroup.Id

        Write-Host "created subscription with name '$($newSubscription.DisplayName)'."
        Start-Sleep -Seconds 15
    }
}

$subscriptions = Get-AzManagementGroupSubscription -GroupName $managementGroup.Name
Write-Host "got '$($subscriptions.Count)'. creating '$($NumberOfUsers)' azure users."
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

    $subscription = $subscriptions | Where-Object { $_.DisplayName -like "*$user*" } | Select-Object -First 1
    Write-Host "granting owner permission to '$($newUser.DisplayName)' on subscription '$($subscription.Id)'."
    $ownerRole = Get-AzRoleDefinition -Name "Owner"
    New-AzRoleAssignment -SignInName $newUser.UserPrincipalName `
        -RoleDefinitionName $ownerRole `
        -Scope $subscription.Id
    Start-Sleep -Seconds 15
}