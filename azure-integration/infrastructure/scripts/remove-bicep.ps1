param (
    [Parameter(Mandatory=$true)]
    [string] $DeploymentStackName,

    [Parameter(Mandatory=$true)]
    [string] $ResourceGroupName
)

Remove-AzResourceGroupDeploymentStack `
  -Name "$DeploymentStackName" `
  -ResourceGroupName "$ResourceGroupName" `
  -DeleteAll