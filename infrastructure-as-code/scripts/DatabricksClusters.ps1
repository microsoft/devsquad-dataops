param(
    [Parameter(Mandatory)] [string] [ValidateSet("dev", "qa", "prod", "sandbox")] $Environment,
    [string] $ClustersPath = "./infrastructure-as-code/databricks/$Environment",
    [string] $DeploymentOutputFile,
    [string] $DatabricksWorkspaceHost
)

$ErrorActionPreference = "Stop"

# Azure Best Practice: Implement stronger environment variable cleanup
function Clear-AllAuthVars {
    param (
        [string]$AuthMethod = "ServicePrincipal" # Options: "ServicePrincipal" or "Token"
    )
    Write-Host "Clearing all authentication environment variables..." -ForegroundColor Yellow
    
    # Force remove all authentication-related variables to prevent conflicts
    if ($AuthMethod -eq "ServicePrincipal") {
        Remove-Item Env:\DATABRICKS_TOKEN -ErrorAction SilentlyContinue
        # Additional check to ensure variables are truly cleared
        if (Test-Path Env:\DATABRICKS_TOKEN) {
            # If Remove-Item doesn't work, try setting to empty string
            $env:DATABRICKS_TOKEN = ""
        }
    }
    elseif ($AuthMethod -eq "Token") {
        Remove-Item Env:\ARM_CLIENT_ID -ErrorAction SilentlyContinue
        Remove-Item Env:\ARM_CLIENT_SECRET -ErrorAction SilentlyContinue
        Remove-Item Env:\ARM_TENANT_ID -ErrorAction SilentlyContinue
    }
}

# Azure Best Practice: Choose single authentication method
function Set-DatabricksAuth {
    param (
        [string]$AuthMethod = "ServicePrincipal" # Options: "ServicePrincipal" or "Token"
    )
    
    # First clear all auth variables
    Clear-AllAuthVars
    
    # Then set only the ones needed for the selected method
    if ($AuthMethod -eq "ServicePrincipal") {
        Write-Host "Configuring Service Principal authentication..." -ForegroundColor Blue
        
        # Check if variables are available in the pipeline
        if ([string]::IsNullOrEmpty($env:ARM_CLIENT_ID) -or 
            [string]::IsNullOrEmpty($env:ARM_CLIENT_SECRET) -or
            [string]::IsNullOrEmpty($env:ARM_TENANT_ID)) {
            throw "Service Principal variables not available in environment"
        }
        
        # These will be read by Databricks CLI
        $env:DATABRICKS_TOKEN = $null  # Explicitly set to null
        
        # Verify service principal variables are set
        Write-Host "Service Principal variables configured"
    }
    elseif ($AuthMethod -eq "Token") {
        Write-Host "Configuring Token-based authentication..." -ForegroundColor Blue
        
        # Check if DATABRICKS_TOKEN is available
        if ([string]::IsNullOrEmpty($env:DATABRICKS_TOKEN)) {
            throw "DATABRICKS_TOKEN not available in environment"
        }
        
        # Nullify SP variables
        $env:ARM_CLIENT_ID = $null
        $env:ARM_CLIENT_SECRET = $null
        $env:ARM_TENANT_ID = $null
    }
    else {
        throw "Invalid authentication method specified"
    }
}

Write-Host "Using Databricks workspace: $env:DATABRICKS_HOST" -ForegroundColor Green
Write-Host "Using Databricks client_id: $env:ARM_CLIENT_ID" -ForegroundColor Green
Write-Host "Using Databricks client_secret: $env:ARM_CLIENT_SECRET" -ForegroundColor Green
Write-Host "Using Databricks tenant_id: $env:ARM_TENANT_ID" -ForegroundColor Green

Set-DatabricksAuth -AuthMethod "ServicePrincipal"

# Azure Best Practice: Don't log sensitive information
Write-Host "Authentication method: $(if ($env:DATABRICKS_TOKEN) {'Token'} else {'Service Principal'})" -ForegroundColor Green

try {
    
    # Azure Best Practice: Verify authentication is correctly configured
    if (-not $env:DATABRICKS_HOST) {
        throw "DATABRICKS_HOST environment variable is required"
    }
    
    if ((-not $env:DATABRICKS_TOKEN) -and (-not ($env:ARM_CLIENT_ID))) {
        throw "Authentication not configured. Either DATABRICKS_TOKEN or Azure SP variables must be set"
    }
    
    # Rest of your script remains the same
    Write-Host "Getting existing clusters in databricks workspace..." -ForegroundColor Blue
    $rawResponse = databricks clusters list --output json
    
    $response = $rawResponse | ConvertFrom-Json
    $existingClusters = $response.clusters

    # Azure Best Practice: Validate resource existence before operations
    $files = Get-ChildItem "$ClustersPath/*.json" -ErrorAction SilentlyContinue
    if (-not $files -or $files.Count -eq 0) {
        Write-Host "##vso[task.logissue type=warning]No cluster definitions found in $ClustersPath"
    }

    $clustersOutput = @{}
    foreach ($file in $files) {
        try {

            # Set timeout duration - Azure best practice is to use reasonable timeouts based on VM size and complexity
            $timeoutDuration = "45m"

            $incomingCluster = Get-Content -Path $file -Raw | ConvertFrom-Json
            $existingCluster = $existingClusters | Where-Object { $_.cluster_name -eq $incomingCluster.cluster_name }

            $count = $existingCluster | Measure-Object
            if ($count.Count -gt 1) {
                Write-Host "##vso[task.logissue type=error]Multiple clusters with name '$($incomingCluster.cluster_name)' found. Cluster names must be unique."
                exit 1
            }

            if ($existingCluster) {
                if ($existingCluster.state -eq "RUNNING" -or $existingCluster.state -eq "TERMINATED") {

                    Write-Host "Cluster already exists. Updating cluster: $($incomingCluster.cluster_name)" -ForegroundColor Blue
                    $incomingCluster | Add-Member -NotePropertyName cluster_id -NotePropertyValue $existingCluster.cluster_id -Force
                    
                    # Azure Best Practice: Use temp files for JSON data with special characters
                    $tempFile = New-TemporaryFile
                    $incomingCluster | ConvertTo-Json -Depth 10 | Set-Content -Path $tempFile
                    
                    # Azure Best Practice: Properly handle JSON file for Databricks CLI
                    $jsonContent = Get-Content -Path $tempFile -Raw

                    databricks clusters edit --json $jsonContent --timeout $timeoutDuration
                    Remove-Item -Path $tempFile -Force
                    
                    Write-Host "##[section]Cluster $($incomingCluster.cluster_name) was updated." -ForegroundColor Green
                }
                else {
                    Write-Host "##vso[task.logissue type=warning]Cluster '$($existingCluster.cluster_name)' is in $($existingCluster.state) state and cannot be updated."
                }
                $clustersOutput.Add($existingCluster.cluster_name, $existingCluster.cluster_id)
            }
            else {
                Write-Host "Creating a new cluster: $($incomingCluster.cluster_name). This can take a while..." -ForegroundColor Blue
                
                # Azure Best Practice: Properly handle JSON file for Databricks CLI
                $jsonContent = Get-Content -Path $file.FullName -Raw

                $rawCreateResponse = databricks clusters create --json $jsonContent --timeout $timeoutDuration

                Write-Host "Raw response: $($rawCreateResponse)"

                $createResponse = $($rawCreateResponse | ConvertFrom-Json)
                $clustersOutput.Add($incomingCluster.cluster_name, $createResponse.cluster_id)
                Write-Host "##[section]Cluster $($incomingCluster.cluster_name)  with ID $($createResponse.cluster_id) was created." -ForegroundColor Green
            }

            if ($DeploymentOutputFile) {
                Write-Host "Saving outputs to $DeploymentOutputFile..." -ForegroundColor Green
                $clustersOutput | ConvertTo-Json | Set-Content -Path $DeploymentOutputFile
            }

        }
        catch {
            Write-Host "##vso[task.logissue type=error]Error processing cluster definition $($file.Name): $_"
            throw $_
        }
    }
    
    # Azure Best Practice: Always return explicit exit code
    exit 0
}
catch {
    Write-Host "##vso[task.logissue type=error]Error in DatabricksClusters.ps1: $_"
    Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
    exit 1
}