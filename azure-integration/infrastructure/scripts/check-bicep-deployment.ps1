param (
    [Parameter(Mandatory=$true)]
    [string] $DeploymentStackName,

    [Parameter(Mandatory=$true)]
    [string] $ResourceGroupName
)

$deploymentStack = Get-AzResourceGroupDeploymentStack `
  -Name "$DeploymentStackName" `
  -ResourceGroupName "$ResourceGroupName"

Write-Host "deployment stack provisioning stack '$($deploymentStack.provisioningState)'"
