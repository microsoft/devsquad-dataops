param(
    [Parameter(Mandatory)] [string] $KeyVaultName,
    [Parameter(Mandatory)] [string] $ComputeResourceGroup,
    [Parameter(Mandatory)] [string] $DatabricksName
)

Write-Host "Installing Databricks Cli..." -ForegroundColor Green
pip install databricks-cli --upgrade

Write-Host "Getting Azure resources..." -ForegroundColor Green
$kv = Get-AzKeyVault -VaultName $KeyVaultName
$dbw = Get-AzDatabricksWorkspace -ResourceGroupName $ComputeResourceGroup -Name $DatabricksName 

Write-Host "Creating the Key Vault secret scope on Databricks..." -ForegroundColor Green
$accessToken = Get-AzAccessToken -ResourceUrl 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d
$env:DATABRICKS_TOKEN = $accessToken.Token
$env:DATABRICKS_HOST = "https://$($dbw.Url)"
Write-Host "URL DBW https://$($dbw.Url)"

$scopesList = databricks secrets list-scopes --output json | ConvertFrom-Json
if (! $scopesList.scopes.name -contains "dataops") {
    databricks secrets create-scope --scope 'dataops' --scope-backend-type AZURE_KEYVAULT --resource-id $kv.ResourceId --dns-name $kv.VaultUri
}

Write-Host "Listing Databricks scope content..." -ForegroundColor Green
databricks secrets list --scope dataops

Write-Host "Finished!" -ForegroundColor Blue