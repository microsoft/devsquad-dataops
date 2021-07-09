param(
    [Parameter(Mandatory)] [string] $ClientID,
    [Parameter(Mandatory)] [securestring] $ClientSecret,
    [Parameter(Mandatory)] [string] $DataResourceGroup,
    [Parameter(Mandatory)] [string] $ComputeResourceGroup,
    [Parameter(Mandatory)] [string] $KeyVaultName,
    [Parameter(Mandatory)] [string] $DataLakeName,
    [Parameter(Mandatory)] [string] $DatabricksName
)

$ErrorActionPreference = "Stop"

$context = Get-AzContext

Write-Host "Getting user and principal information..." -ForegroundColor Green
$user = Get-AzADUser -UserPrincipalName $context.Account.Id
$principal = Get-AzADServicePrincipal -ApplicationId $ClientID

Write-Host "Getting Azure resources..." -ForegroundColor Green
$kv = Get-AzKeyVault -VaultName $KeyVaultName
$lake = Get-AzStorageAccount -ResourceGroupName $DataResourceGroup -Name $DataLakeName 
$dbw = Get-AzDatabricksWorkspace -ResourceGroupName $ComputeResourceGroup -Name $DatabricksName 

Write-Host "Adding permissions to user on Key Vault..." -ForegroundColor Green
$userPermissions = $kv.AccessPolicies | Where-Object { $_.ObjectId -eq $user.Id }
$secretPermissions = $userPermissions.PermissionsToSecrets
if (! $secretPermissions || ! $userPermissions.PermissionsToSecrets.Contains("set")) {
    Set-AzKeyVaultAccessPolicy -VaultName $KeyVaultName -ObjectId $user.Id -PermissionsToSecrets "set"
}

Write-Host "Setting service principal secrets on Key Vault..." -ForegroundColor Green
Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name "tenantId" -SecretValue $(ConvertTo-SecureString $context.Tenant.Id -AsPlainText -Force)
Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name "clientId" -SecretValue $(ConvertTo-SecureString $ClientID -AsPlainText -Force)
Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name "clientSecret" -SecretValue $ClientSecret

Write-Host "Assigning roles to the service principal on the data lake..." -ForegroundColor Green
$assigment = Get-AzRoleAssignment -ObjectId $principal.Id -Scope $lake.Id | Where-Object { $_.RoleDefinitionName -eq "Storage Blob Data Contributor" }
if(! $assigment){
    New-AzRoleAssignment -ObjectId $principal.Id -Scope $lake.Id -RoleDefinitionName "Storage Blob Data Contributor" 
}

Write-Host "Finished! Please configure databricks with the following values:" -ForegroundColor Blue
Write-Host "`t Scope:`t`t dataops" -ForegroundColor Cyan
Write-Host "`t DNS Name:`t $($kv.VaultUri)" -ForegroundColor Cyan
Write-Host "`t Resource ID:`t $($kv.ResourceId)" -ForegroundColor Cyan

Start-Process "https://$($dbw.Url)#secrets/createScope"
