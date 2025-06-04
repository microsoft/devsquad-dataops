param(
    [Parameter(Mandatory)] [string] [ValidateSet("dev", "qa", "prod", "sandbox")] $Environment,
    [Parameter(Mandatory)] [string] $DataLakeName,
    [Parameter(Mandatory)] [string] $DatabricksName,
    [Parameter(Mandatory)] [string] $KeyVaultName,
    [string] $SolutionParametersFile = "./infrastructure-as-code/infrastructure/parameters/parameters.$Environment.json"
)

# Access token from environment variable
$DatabricksToken = $env:DATABRICKS_TOKEN

if (-not $DatabricksToken) {
    Write-Error "DATABRICKS_TOKEN environment variable is not set"
    exit 1
}

$ErrorActionPreference = "Stop"

Write-Host "DATABRICKS_TOKEN is set and ready to use." -ForegroundColor Green

Write-Host "Getting variables from Library file..." -ForegroundColor Green

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
    
    [securestring]$servicePrincipalSecret

    try {

        Write-Host "Trying generate new client secret..." -ForegroundColor Green
        $startDate = Get-Date
        $endDate = $startDate.AddMonths(6)

        $clientSecret = New-AzADSpCredential -ObjectId $servicePrincipal.Id -StartDate $startDate -EndDate $endDate

        $servicePrincipalSecret = $clientSecret.SecretText

        Write-Host "New Secret was generated for Service Principal " $servicePrincipalSecret -ForegroundColor Yellow

        $secureSecret = ConvertTo-SecureString $servicePrincipalSecret -AsPlainText -Force

    } 
    catch {
        Write-Host "Fail to generate a new secret for the Service Principal. Maybe without AAD permission on Application administrators Role" -ForegroundColor Green
        Write-Host "Use the first secret created..." -ForegroundColor Green

        $servicePrincipalSecret =  ConvertTo-SecureString (($ParameterContent).PSObject.Properties["parameters"].Value.servicePrincipalSecret.Value) -AsPlainText -Force

    }

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
    Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name "clientId" -SecretValue $(ConvertTo-SecureString $servicePrincipal.AppId -AsPlainText -Force)
    Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name "clientSecret" -SecretValue $secureSecret

    Write-Host "Assigning roles to the service principal on the data lake..." -ForegroundColor Green
    $assigment = Get-AzRoleAssignment -ObjectId $servicePrincipal.Id -Scope $lake.Id | Where-Object { $_.RoleDefinitionName -eq "Storage Blob Data Contributor" }
    if(! $assigment){
        New-AzRoleAssignment -ObjectId $servicePrincipal.Id -Scope $lake.Id -RoleDefinitionName "Storage Blob Data Contributor" 
    }

}
else {
    Write-Host "No Service Principal founded" -ForegroundColor Red
}

Write-Host "Finished!" -ForegroundColor Blue
