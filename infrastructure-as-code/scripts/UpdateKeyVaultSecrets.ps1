param(
    [Parameter(Mandatory)] [string] $DeploymentOutputFile
)

Write-Host "Getting variables from $DeploymentOutputFile file..."
$DeploymentOutput = Get-Content -Path $DeploymentOutputFile | ConvertFrom-Json -AsHashtable
$ResourceGroupName = $DeploymentOutput["resourceGroupData"]
$StorageAccountName = $DeploymentOutput["dataSourceStorageAccountName"]
$keyVaultName = $DeploymentOutput["keyVaultName"]

$ErrorActionPreference = "Stop"

$context = Get-AzContext
Write-Host "Getting Service Principal information..." -ForegroundColor Green
$servicePrincipal = Get-AzADServicePrincipal -ApplicationId $context.Account.Id

Write-Host "Reading the Key Vault..." -ForegroundColor Green
$kv = Get-AzKeyVault -VaultName $KeyVaultName

Write-Host "Adding permissions to user on Key Vault..." -ForegroundColor Green
$userPermissions = $kv.AccessPolicies | Where-Object { $_.ObjectId -eq $servicePrincipal.Id }
$secretPermissions = $userPermissions.PermissionsToSecrets
if (! $secretPermissions || ! $userPermissions.PermissionsToSecrets.Contains("set")) {
    Set-AzKeyVaultAccessPolicy -VaultName $KeyVaultName -ObjectId $servicePrincipal.Id -PermissionsToSecrets "set"
}

Write-Host "Add the Key Vault Secret..."
$Key1 = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Value[0] 
$ConnectionString = "DefaultEndpointsProtocol=https;AccountName=$StorageAccountName;AccountKey=$Key1;EndpointSuffix=core.windows.net"

Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "StorageAccountConnectionString" -SecretValue $(ConvertTo-SecureString $ConnectionString -AsPlainText)
