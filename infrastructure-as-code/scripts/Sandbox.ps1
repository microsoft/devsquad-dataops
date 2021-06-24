param(
    [string] $Location = "eastus",
    [string] $SolutionName = "dataops",
    [switch] $AutoApprove,
    [switch] $Test,
    [switch] $Lint
)

$ErrorActionPreference = "Stop"
function Get-Confirmation() {
    if (!$AutoApprove) {
        $context = Get-AzContext
        $confirmation = Read-Host "Are you sure you want to deploy sandbox resources on the subscription $($context.Subscription.Name) ($($context.Subscription.Id))? (Y/n)"
        if ($confirmation -ne 'Y') {
            Write-Error "Setup cancelled."
        }
    }
}

$environment = "sandbox"
$version = git branch --show-current | % { $_.replace("/", "-") } 
$outputFile = "sandbox.json"

if ($Lint) {
    Write-Host "Running linter" -ForegroundColor Blue
    & $PSScriptRoot\Lint.ps1
}

Get-Confirmation
Write-Host "Starting planning for $environment" -ForegroundColor Blue
& $PSScriptRoot\Plan.ps1 -Environment $environment -Version $version -Location $Location -SolutionName $SolutionName

Get-Confirmation
Write-Host "Starting deploying ARM to $environment" -ForegroundColor Blue
& $PSScriptRoot\Deploy.ps1 -Environment $environment -Version $version -Location $Location -SolutionName $SolutionName -DeploymentOutputFile $outputFile

Write-Host "Setting environment variables from ARM outputs..." -ForegroundColor Green
$deploymentOutput = Get-Content -Path $outputFile | ConvertFrom-Json -AsHashtable
foreach ($output in $deploymentOutput.GetEnumerator()) {
    $key = [regex]::replace($output.Key, '([A-Z])(.)', { "_" +  $args[0]}).ToUpper() #camelCase to SNAKE_CASE
    Set-Item "env:ACC_TEST_$key" $output.Value
}
Remove-Item $outputFile

Write-Host "Starting deploying DBW clusters to $environment" -ForegroundColor Blue
& $PSScriptRoot\DatabricksClusters.ps1 -Environment $environment -DatabricksWorkspaceHost "https://$($deploymentOutput.databricksWorkspaceUrl)/"

if ($Test) {
    Write-Host "Running acceptance tests for $environment" -ForegroundColor Blue
    Invoke-Pester -Output Detailed ./tests/ -ExcludeTagFilter "prod"
}

Write-Host "Finished" -ForegroundColor Blue
