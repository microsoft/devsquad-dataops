param(
    [Parameter(Mandatory)] [string] [ValidateSet("dev", "qa", "prod", "sandbox")] $Environment,
    [Parameter(Mandatory)] [string] $DeploymentOutputFile,
    [string] $SolutionParametersFile = "./infrastructure-as-code/infrastructure/parameters/parameters.$Environment.json"
)

$ErrorActionPreference = "Stop"

Write-Host "Getting variables from $DeploymentOutputFile file..." -ForegroundColor Green
$DeploymentOutput = Get-Content -Path $DeploymentOutputFile | ConvertFrom-Json -AsHashtable
$DataLakeName = $DeploymentOutput["dataLakeName"]
$DatabricksName = $DeploymentOutput["databricksName"]
$keyVaultName = $DeploymentOutput["keyVaultName"]

Write-Host "Getting variables from $SolutionParametersFile file..." -ForegroundColor Green
$ParameterContent = Get-Content -Path $SolutionParametersFile | ConvertFrom-Json
$DataResourceGroup = ($ParameterContent).PSObject.Properties["parameters"].Value.resourceGroupData.Value
$ComputeResourceGroup =  ($ParameterContent).PSObject.Properties["parameters"].Value.resourceGroupCompute.Value
$ServicePrincipalName = ($ParameterContent).PSObject.Properties["parameters"].Value.servicePrincipal.Value

Write-Host "Parameter file " $SolutionParametersFile
Write-Host "ServicePrincipalName " $ServicePrincipalName

$context = Get-AzContext
Write-Host "Getting user and principal information..." -ForegroundColor Green
$servicePrincipal = Get-AzADServicePrincipal -DisplayName $ServicePrincipalName

if ($servicePrincipal) {
    
    Write-Host "Generating new client secret..." -ForegroundColor Green
    $startDate = Get-Date
    $endDate = $startDate.AddMonths(6)

    $clientSecret = New-AzADSpCredential -ObjectId $servicePrincipal.Id -StartDate $startDate -EndDate $endDate
    Write-Host "Secret generated " $clientSecret -ForegroundColor Yellow

    Write-Host "Getting Azure resources..." -ForegroundColor Green
    $kv = Get-AzKeyVault -VaultName $KeyVaultName
    $lake = Get-AzStorageAccount -ResourceGroupName $DataResourceGroup -Name $DataLakeName 
    $dbw = Get-AzDatabricksWorkspace -ResourceGroupName $ComputeResourceGroup -Name $DatabricksName 

    Write-Host "Adding permissions to user on Key Vault..." -ForegroundColor Green
    $userPermissions = $kv.AccessPolicies | Where-Object { $_.ObjectId -eq $servicePrincipal.Id }
    $secretPermissions = $userPermissions.PermissionsToSecrets
    if (! $secretPermissions || ! $userPermissions.PermissionsToSecrets.Contains("set")) {
        Set-AzKeyVaultAccessPolicy -VaultName $KeyVaultName -ObjectId $servicePrincipal.Id -PermissionsToSecrets "set"
    }

    Write-Host "Setting service principal secrets on Key Vault..." -ForegroundColor Green
    Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name "tenantId" -SecretValue $(ConvertTo-SecureString $context.Tenant.Id -AsPlainText -Force)
    Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name "clientId" -SecretValue $(ConvertTo-SecureString $ClientID -AsPlainText -Force)
    Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name "clientSecret" -SecretValue $clientSecret

    Write-Host "Assigning roles to the service principal on the data lake..." -ForegroundColor Green
    $assigment = Get-AzRoleAssignment -ObjectId $principal.Id -Scope $lake.Id | Where-Object { $_.RoleDefinitionName -eq "Storage Blob Data Contributor" }
    if(! $assigment){
        New-AzRoleAssignment -ObjectId $principal.Id -Scope $lake.Id -RoleDefinitionName "Storage Blob Data Contributor" 
    }

    Write-Host "Creating the Key Vault secret scope on Databricks..." -ForegroundColor Green
    $accessToken = Get-AzAccessToken -ResourceUrl 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d
    $env:DATABRICKS_TOKEN = $accessToken.Token
    $env:DATABRICKS_HOST = "https://$($dbw.Url)"
    Write-Host "URL DBW https://$($dbw.Url)"
    $scopesList = databricks secrets list-scopes --output json | ConvertFrom-Json
    if (! $scopesList.scopes.name -contains "dataops") {
        databricks secrets create-scope --scope 'dataops' --scope-backend-type AZURE_KEYVAULT --resource-id $kv.ResourceId --dns-name $kv.VaultUri
    }
}
else {
    Write-Host "No Service Principal founded" -ForegroundColor Red
}

Write-Host "Finished!" -ForegroundColor Blue
