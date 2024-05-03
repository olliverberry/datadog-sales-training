param (
    [Parameter(Mandatory=$true)]
    [string] $DeploymentStackName,

    [Parameter(Mandatory=$true)]
    [string] $DefaultResourceGroupName,

    [Parameter(Mandatory=$false)]
    [hashtable] $TemplateParameters
)

New-AzResourceGroupDeploymentStack `
    -Name "$DeploymentStackName" `
    -ResourceGroupName "$DefaultResourceGroupName" `
    -TemplateFile "../bicep/main.bicep" `
    -TemplateParameterObject $TemplateParameters
    -DenySettingsMode "none"