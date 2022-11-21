param(
    [Parameter(Mandatory)] [string] $AzureDevOpsPAT,
    [Parameter(Mandatory)] [string] $AzureDevOpsOrganization,
    [Parameter(Mandatory)] [string] $AzureDevOpsProject,    
    [Parameter(Mandatory)] [string] $SolutionName,
    [Parameter(Mandatory)] [string] $Environment
)

Write-Host "Login Azure DevOps Extension"
Write-Output $AzureDevOpsPAT | az devops login

Write-Host "Set default Azure DevOps organization and project"
az devops configure --defaults organization=$AzureDevOpsOrganization project="$AzureDevOpsProject"

$GroupName = "dataops-iac-cd-output-$Environment"
$GroupId = $(az pipelines variable-group list --query "[?name=='$GroupName'].id" -o tsv)

Write-Host "Getting variables from Variable Group $GroupName..." -ForegroundColor Green
$json = $(az pipelines variable-group variable list --group-id $GroupId)
$variables = $json | ConvertFrom-Json -AsHashtable

Write-Host "Setting environment variables from ARM outputs..." -ForegroundColor Green
foreach ($variable in $variables.GetEnumerator()) {
    $key = [regex]::replace($variable.Key, '([A-Z])(.)', { "_" + $args[0] }).ToUpper() #camelCase to SNAKE_CASE
    Set-Item "env:ACC_TEST_$key" $variable.Value.value
}

Write-Host "Filtering environments that should be excluded..." -ForegroundColor Green
$filtered = "dev", "qa", "prod" | Where-Object { $_ -ne $Environment }

Write-Host "Running acceptance tests..." -ForegroundColor Green
Invoke-Pester -CI -Output Detailed ../infrastructure-as-code/tests/ -ExcludeTagFilter $filtered
