param (
    # Azure DevOps organization where you want to create this HOL resources
    [parameter(mandatory=$true)]
    [string]$projectAlias = '<projectAlias>'
)

$filter = ("rg-" + $projectAlias + "-")

$myprocss = Start-Process "Get-AzResourceGroup | ? ResourceGroupName -match $filter | Select-Object ResourceGroupName"
$myprocss.WaitForExit()

$answer = read-host -prompt "Found missing roles. Press 'y' to delete them."
$yesList = 'yes','y'

if ($yesList -contains $answer.ToLower()) {
    Write-Host $answer
} else {
    Write-Host "Your resources were not deleted. "
}

