param (
    # Azure DevOps organization where you want to create this HOL resources
    [parameter(mandatory=$true)]
    [string]$orgName = '<orgName>',

    # Azure DevOps organization where you want to create this HOL resources
    [parameter(mandatory=$true)]
    [string]$projectName = '<projectName>',
    
    # Simple alias for the project (less than 8 characters)
    [parameter(mandatory=$true)]
    [string]$projectAlias = '<projectAlias>',

    # ID of the Azure Subscription where you want to create this HOL resources
    [parameter(mandatory=$true)]
    [string]$subscriptionId = '<subscriptionId>',

    # ID of the Azure Subscription where you want to create this HOL resources
    [string]$configsTemplate = 'quickstart/configs/cloud-setup/template.json',

    # ID of the Azure Subscription where you want to create this HOL resources
    [parameter(mandatory=$true)]
    [string]$configsOutput = 'quickstart/configs/cloud-setup/hol.json'
)

(Get-Content $configsTemplate) `
    -replace '<projectName>', $projectName `
    -replace '<projectAlias>', $projectAlias `
    -replace '<orgName>', $orgName `
    -replace '<subscriptionId>', $subscriptionId |
  Out-File $configsOutput