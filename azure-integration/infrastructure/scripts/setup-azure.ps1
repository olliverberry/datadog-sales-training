param (
    [Parameter(Mandatory=$true)]
    [int] $NumberOfUsers,

    [Parameter(Mandatory=$true)]
    [string] $BillingString,

    [Parameter(Mandatory=$true)]
    [securestring] $Password,

    [Parameter(Mandatory=$true)]
    [string] $DomainName
)

$ManagementGroupName = "datadog-sales-training"
$managementGroup = Get-AzManagementGroup -GroupName $ManagementGroupName -ErrorAction SilentlyContinue
if (-not $managementGroup) {
    Write-Host "management group '$ManagementGroupName' does not exist. creating..."
    $managementGroup = New-AzManagementGroup -GroupName $ManagementGroupName -DisplayName 'Datadog Sales Training'
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

        Write-Host "created subscription with name '$($newSubscription.Name)'."
        Start-Sleep -Seconds 15
    }
}

$subscriptions = Get-AzManagementGroupSubscription -GroupName $managementGroup.Name
for ($i = 1; $i -le $NumberOfUsers; $i++) {
    $user = "user$i"
    $upn = "$user@$DomainName"
    $newUser = New-AzADUser -DisplayName $user `
        -Password $Password `
        -AccountEnabled $true `
        -MailNickname $user `
        -UserPrincipalName $upn
    Start-Sleep -Seconds 15

    $subscription = ($subscriptions | Where-Object { $_.Name -like "*$user*" })[0]
    $ownerRole = Get-AzRoleDefinition -Name "Owner"
    New-AzRoleAssignment -SignInName $newUser.UserPrincipalName `
        -RoleDefinitionName $ownerRole `
        -Scope "/subscriptions/$($subscription.Id)"
    Start-Sleep -Seconds 15
}