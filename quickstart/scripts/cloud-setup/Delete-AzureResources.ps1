param (
    # Azure DevOps organization where you want to create this HOL resources
    [parameter(mandatory=$true)]
    [string]$projectName = '<projectName>',
    
    # Simple alias for the project (less than 8 characters)
    [parameter(mandatory=$true)]
    [string]$projectAlias = '<projectAlias>'
)

$filter = ("rg-" + $projectAlias + "-")

$myServicePrincipals = Get-AzADServicePrincipal -DisplayName ("SP-"+$projectName+"-DevTest") | Select-Object DisplayName
Write-Host "`nService Principal`n-----------------"
$myServicePrincipals | ForEach-Object  {
    Write-Host $_.DisplayName
}

$myResourceGroups = Get-AzResourceGroup | Where-Object ResourceGroupName -match $filter | Select-Object ResourceGroupName
Write-Host "`nResource Group`n-----------------"
$myResourceGroups | ForEach-Object  {
    Write-Host $_.ResourceGroupName
}

$answer = read-host -prompt "`nPress 'y' to delete all the resources listed above."
$yesList = 'yes','y'

if ($yesList -contains $answer.ToLower()) {
    if ($myServicePrincipals.Count -gt 0){
        Get-AzADServicePrincipal -DisplayName ("SP-"+$projectName+"-DevTest") | ForEach-Object { Remove-AzADServicePrincipal -ApplicationId $_.ApplicationId -Force }
        Get-AzADApplication -DisplayName ("SP-"+$projectName+"-DevTest") | ForEach-Object { Remove-AzADApplication -ApplicationId $_.ApplicationId -Force }
    }
    if ($myResourceGroups.Count -gt 0){
        Get-AzResourceGroup | Where-Object ResourceGroupName -match $filter | Remove-AzResourceGroup -AsJob -Force
    }
} else {
    Write-Host "[Command Skipped] Your resources were not deleted."
}