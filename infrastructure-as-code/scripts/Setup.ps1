param(
    [Parameter(Mandatory)] [string] [ValidateSet("dev", "qa", "prod", "sandbox")] $Environment,
    [string] $Location = "eastus",
    [string] $SolutionName = "dataops",
    [string] [ValidateLength(1, 4)] $SandboxUniqueName
)

$ErrorActionPreference = "Stop"

if ($Environment -eq "sandbox" -and ! $SandboxUniqueName) {
    Write-Error "When creating a sandbox environment, please set -SandboxUniqueName"
}

$context = Get-AzContext

$confirmation = Read-Host "Are you sure you want to create a $Environment environment on the subscription $($context.Subscription.Name) ($($context.Subscription.Id))? (Y/n)"
if ($confirmation -ne 'Y') {
    Write-Error "Setup cancelled. If you intend to switch subscriptions, please use 'Set-AzContext -Subscription <guid>'"
}

Write-Host "Starting creation of $SolutionName RGs for $Environment" -ForegroundColor Blue

Write-Host "Creating resource group for data..." -ForegroundColor Green
New-AzResourceGroup -Name "rg-$SolutionName-data-$Environment" -Location $Location -Force

Write-Host "Creating resource group for compute..." -ForegroundColor Green
New-AzResourceGroup -Name "rg-$SolutionName-compute-$Environment" -Location $Location -Force

Write-Host "Creating resource group for machine learning..." -ForegroundColor Green
New-AzResourceGroup -Name "rg-$SolutionName-ml-$Environment" -Location $Location -Force

Write-Host "Creating resource group for network..." -ForegroundColor Green
New-AzResourceGroup -Name "rg-$SolutionName-network-$Environment" -Location $Location -Force

Write-Host "Creating resource group for template specs..." -ForegroundColor Green
New-AzResourceGroup -Name "rg-dataops-template-specs" -Location $Location -Force

Write-Host "Registering resource providers..." -ForegroundColor Green
$Providers = "Microsoft.Storage", "Microsoft.Compute", "Microsoft.MachineLearningServices", "Microsoft.ContainerRegistry", `
"Microsoft.Databricks", "Microsoft.ContainerService", "Microsoft.Kubernetes", "Microsoft.KubernetesConfiguration", `
"Microsoft.KeyVault", "Microsoft.Insights", "Microsoft.DataFactory", "Microsoft.DataLakeStore"
$Providers | Register-AzResourceProvider -ProviderNamespace { $_ }

if ($Environment -eq "sandbox") {
    Write-Host "Creating Sandbox parameters file..." -ForegroundColor Green
    $devParamsFile = ".\infrastructure\parameters\parameters.dev.template.json"
    $sandboxParamsFile = ".\infrastructure\parameters\parameters.sandbox.json"
    $sandboxParams = Get-Content -Path $devParamsFile -Raw
    $sandboxParams = $sandboxParams.Replace('-dev', '-sandbox')
    $sandboxParams = $sandboxParams.Replace('"value": "dev"', "`"value`": `"$SandboxUniqueName`"")
    $sandboxParams | Set-Content -Path $sandboxParamsFile

    Write-Host "Downloading ARM Template Test Toolkit..." -ForegroundColor Green
    New-Item './ttk' -ItemType Directory -Force
    Invoke-WebRequest -Uri 'https://aka.ms/arm-ttk-latest' -OutFile './ttk/arm-ttk.zip' -Verbose
    Expand-Archive -Path './ttk/*.zip' -DestinationPath './ttk' -Verbose -Force
}

Write-Host "Finished" -ForegroundColor Blue
