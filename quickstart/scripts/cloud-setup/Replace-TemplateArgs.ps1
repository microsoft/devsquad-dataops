param (
    # Azure DevOps organization where you want to create this HOL resources
    [parameter(mandatory=$true)]
    [string]$orgName = '<orgName>',

    # Azure DevOps organization where you want to create this HOL resources
    [parameter(mandatory=$true)]
    [string]$projectName = '<projectName>',
    
    # ID of the Azure Subscription where you want to create this HOL resources
    [parameter(mandatory=$true)]
    [string]$subscriptionId = '<subscriptionId>',

    # ID of the Azure Subscription where you want to create this HOL resources
    [string]$configsTemplate = 'quickstart/configs/cloud-setup/template.json',

    # ID of the Azure Subscription where you want to create this HOL resources
    [string]$configsOutput = 'quickstart/configs/cloud-setup/hol.json'
)

$projectAlias = GenerateRandomProjectAlias
Write-Output "Project Alias: '$projectAlias'"

(Get-Content $configsTemplate) `
    -replace '<projectName>', $projectName `
    -replace '<projectAlias>', $projectAlias.ToLower() `
    -replace '<orgName>', $orgName `
    -replace '<subscriptionId>', $subscriptionId |
  Out-File $configsOutput

function GenerateRandomProjectAlias {
    [cmdletbinding()]
    param ()
    $randomLetter = (65..90) + (97..122) | Get-Random -Count 1 | % {[char]$_} 
    $gUUID = New-Guid
    return $randomLetter + $gUUID.Guid.Split("-")[0].Substring(0, 7)
}