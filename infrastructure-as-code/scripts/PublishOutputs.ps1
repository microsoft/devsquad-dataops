param(
    [Parameter(Mandatory)] [string] $AzureDevOpsPAT,
    [Parameter(Mandatory)] [string] $AzureDevOpsOrganization,
    [Parameter(Mandatory)] [string] $AzureDevOpsProject,
    [Parameter(Mandatory)] [string] $GroupName,
    [Parameter(Mandatory)] [string] $DeploymentOutputFile
)

Write-Host "Login Azure DevOps Extension"
Write-Output $AzureDevOpsPAT | az devops login

Write-Host "Set default Azure DevOps organization and project"
az devops configure --defaults organization=$AzureDevOpsOrganization project="$AzureDevOpsProject"

$GroupId = $(az pipelines variable-group list --query "[?name=='$GroupName'].id" -o tsv)

if (! $GroupId) {
    Write-Host "Creating variable group $GroupName ..."
    $GroupId = $(az pipelines variable-group create --name $GroupName --authorize --variable createdAt="$(Get-Date)" --query "id" -o tsv)

    if (! $GroupId) {
        Write-Error "The build agent does not have permissions to create variable groups"
        exit 1
    }
}

Write-Host "Getting variables from $DeploymentOutputFile file..."
$DeploymentOutput = Get-Content -Path $DeploymentOutputFile | ConvertFrom-Json -AsHashtable

Write-Host "Setting Variable Group variables from ARM outputs..."
foreach ($output in $DeploymentOutput.GetEnumerator()) {
    $name = $output.Key
    $value = $output.Value

    Write-Host "Trying to update variable $key..."
    if (! (az pipelines variable-group variable update --group-id $GroupId --name $name --value $value)) { 
        Write-Host "Creating variable $key..."
        az pipelines variable-group variable create --group-id $GroupId --name $name --value $value
    }
}
