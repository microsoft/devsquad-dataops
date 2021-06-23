param(
    [Parameter(Mandatory)] [string] [ValidateSet("dev", "qa", "prod", "sandbox")] $Environment,
    [string] $ClustersPath = "./infrastructure-as-code/databricks/$Environment",
    [string] $DeploymentOutputFile,
    [string] $DatabricksWorkspaceHost
)

$ErrorActionPreference = "Stop"

if ($Environment -eq "sandbox") {
    $tokenResponse = $(az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d | ConvertFrom-Json)
    $env:DATABRICKS_TOKEN = $tokenResponse.accessToken
    $env:DATABRICKS_HOST = $DatabricksWorkspaceHost
}

Write-Host "Getting existing clusters..." -ForegroundColor Blue
$rawResponse = databricks clusters list --output json
$rawResponse

$response = $rawResponse | ConvertFrom-Json
$existingClusters = $response.clusters

$files = Get-ChildItem "$ClustersPath/*.json"
Write-Host "The following cluster definitions were found:" -ForegroundColor Blue
$files

$clustersOutput = @{}
foreach ($file in $files) {
    $incomingCluster = Get-Content -Path $file -Raw | ConvertFrom-Json
    $existingCluster = $existingClusters | Where-Object { $_.cluster_name -eq $incomingCluster.cluster_name }

    $count = $existingCluster | Measure-Object
    if ($count.Count -gt 1) {
        Write-Error "Multiple clusters with the same name were find. This is not allowed. Please rename one of the clusters."
    }

    if ($existingCluster) {
        if ($existingCluster.state -eq "RUNNING" -or $existingCluster.state -eq "TERMINATED") {
            Write-Host "Cluster $($incomingCluster.cluster_name) already exists. Updating..." -ForegroundColor Blue
            $incomingCluster | Add-Member -NotePropertyName cluster_id -NotePropertyValue $existingCluster.cluster_id
            $updatedCluster = $incomingCluster | ConvertTo-Json -Compress | % { $_.replace('"', '\"') } 
            databricks clusters edit --json $updatedCluster
            Write-Host "Cluster $($incomingCluster.cluster_name) was updated." -ForegroundColor Green
        }
        else {
            Write-Host "Cluster $($existingCluster.cluster_name) was in Restarting/Pending state and could not be updated." -ForegroundColor Yellow
        }
        $clustersOutput.Add($existingCluster.cluster_name, $existingCluster.cluster_id)
    }
    else {
        Write-Host "Cluster $($incomingCluster.cluster_name) does not exist. Creating..." -ForegroundColor Blue
        $rawResponse = databricks clusters create --json-file $file.FullName
        $rawResponse
        $response = $($rawResponse | ConvertFrom-Json)
        $clustersOutput.Add($incomingCluster.cluster_name, $response.cluster_id)
        Write-Host "Cluster $($incomingCluster.cluster_name) was updated." -ForegroundColor Green
    }
}

if ($DeploymentOutputFile) {
    Write-Host "Saving outputs to $DeploymentOutputFile..." -ForegroundColor Green
    $clustersOutput | ConvertTo-Json | Set-Content -Path $DeploymentOutputFile
}