Using module ./Common.psm1
Using module ./RepoOperations.psm1
Using module ./Logging.psm1

function CreateAzDevOpsVariableGroups {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)] [hashtable] $RepoConfiguration
    )
    
    [Argument]::AssertIsNotNull("RepoConfiguration", $RepoConfiguration)
    
    CreateAzureDevOpsVariableGroup -VariableGroupName "dataops-iac-cd-output-dev" -AzureDevOpsOrganizationURI $RepoConfiguration.AzureDevOpsOrganizationURI -AzureDevOpsProject $RepoConfiguration.AzureDevOpsProject
    CreateAzureDevOpsVariableGroup -VariableGroupName "dataops-iac-cd-output-qa" -AzureDevOpsOrganizationURI $RepoConfiguration.AzureDevOpsOrganizationURI -AzureDevOpsProject $RepoConfiguration.AzureDevOpsProject
    CreateAzureDevOpsVariableGroup -VariableGroupName "dataops-iac-cd-output-prod" -AzureDevOpsOrganizationURI $RepoConfiguration.AzureDevOpsOrganizationURI -AzureDevOpsProject $RepoConfiguration.AzureDevOpsProject
    CreateAzureDevOpsVariableGroup -VariableGroupName "lib-versions" -AzureDevOpsOrganizationURI $RepoConfiguration.AzureDevOpsOrganizationURI -AzureDevOpsProject $RepoConfiguration.AzureDevOpsProject
    CreateAzureDevOpsVariable -VariableGroupName "lib-versions" -AzureDevOpsOrganizationURI $RepoConfiguration.AzureDevOpsOrganizationURI -AzureDevOpsProject $RepoConfiguration.AzureDevOpsProject -VariableName "MAJOR" -VariableValue "0"
    CreateAzureDevOpsVariable -VariableGroupName "lib-versions" -AzureDevOpsOrganizationURI $RepoConfiguration.AzureDevOpsOrganizationURI -AzureDevOpsProject $RepoConfiguration.AzureDevOpsProject -VariableName "MINOR" -VariableValue "1"
    CreateAzureDevOpsVariable -VariableGroupName "lib-versions" -AzureDevOpsOrganizationURI $RepoConfiguration.AzureDevOpsOrganizationURI -AzureDevOpsProject $RepoConfiguration.AzureDevOpsProject -VariableName "PATCH" -VariableValue "0"
    CreateAzureDevOpsVariable -VariableGroupName "lib-versions" -AzureDevOpsOrganizationURI $RepoConfiguration.AzureDevOpsOrganizationURI -AzureDevOpsProject $RepoConfiguration.AzureDevOpsProject -VariableName "VERSION" -VariableValue "0"
}

function GetAzureDevOpsVariableGroup {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)] [string] $VariableGroupName,
        [Parameter(Mandatory)] [uri] $AzureDevOpsOrganizationURI,
        [Parameter(Mandatory)] [string] $AzureDevOpsProject
    )
    [Argument]::AssertIsNotNullOrEmpty("VariableGroupName", $VariableGroupName)

    Write-Verbose "Getting variables from Variable Group $VariableGroupName..."

    $GroupId = $(az pipelines variable-group list --organization=$AzureDevOpsOrganizationURI --project="$AzureDevOpsProject" --query "[?name=='$VariableGroupName'].id" -o tsv)

    Write-Verbose "Variable Group Id: $GroupId"

    $json = $(az pipelines variable-group variable list --group-id $GroupId --organization=$AzureDevOpsOrganizationURI --project="$AzureDevOpsProject")
    $variables = $json | ConvertFrom-Json -AsHashtable

    return  $variables
}

function CreateAzureDevOpsVariableGroup {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)] [string] $VariableGroupName,
        [Parameter(Mandatory)] [uri] $AzureDevOpsOrganizationURI,
        [Parameter(Mandatory)] [string] $AzureDevOpsProject        
    )
    [Argument]::AssertIsNotNullOrEmpty("VariableGroupName", $VariableGroupName)

    $GroupId = $(az pipelines variable-group list --organization=$AzureDevOpsOrganizationURI --project="$AzureDevOpsProject" --query "[?name=='$VariableGroupName'].id" -o tsv)

    if (! $GroupId) {
        Write-Verbose "Creating variable group $VariableGroupName ..."
        $GroupId = $(az pipelines variable-group create --organization=$AzureDevOpsOrganizationURI --project="$AzureDevOpsProject" --name $VariableGroupName --authorize --variable createdAt="$(Get-Date)" --query "id" -o tsv)

        if (! $GroupId) {
            Write-Error "The build agent does not have permissions to create variable groups"
            exit 1
        }
    }
    return $GroupId
}

function CreateAzureDevOpsVariable {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)] [string] $VariableGroupName,
        [Parameter(Mandatory)] [uri] $AzureDevOpsOrganizationURI,
        [Parameter(Mandatory)] [string] $AzureDevOpsProject,        
        [Parameter(Mandatory)] [string] $VariableName,
        [Parameter(Mandatory)] [string] $VariableValue
    )
    [Argument]::AssertIsNotNullOrEmpty("VariableGroupName", $VariableGroupName)
    [Argument]::AssertIsNotNullOrEmpty("VariableName", $VariableName)
    [Argument]::AssertIsNotNullOrEmpty("VariableValue", $VariableValue)

    $GroupId = $(az pipelines variable-group list --query "[?name=='$VariableGroupName'].id" --organization=$AzureDevOpsOrganizationURI --project="$AzureDevOpsProject" -o tsv)

    if (! $GroupId) {
        Write-Verbose "Creating variable group $VariableGroupName ..."
        $GroupId = $(az pipelines variable-group create --name $VariableGroupName --authorize --variable createdAt="$(Get-Date)" --query "id" --organization=$AzureDevOpsOrganizationURI --project="$AzureDevOpsProject" -o tsv)

        if (! $GroupId) {
            Write-Error "The build agent does not have permissions to create variable groups"
            exit 1
        }
    }

    Write-Verbose "Trying to update variable $VariableName..."
    if (! (az pipelines variable-group variable update --group-id $GroupId --name $VariableName --value $VariableValue --organization=$AzureDevOpsOrganizationURI --project="$AzureDevOpsProject")) { 
        Write-Verbose "Creating variable $key..."
        az pipelines variable-group variable create --group-id $GroupId --name $VariableName --value $VariableValue --organization=$AzureDevOpsOrganizationURI --project="$AzureDevOpsProject"
    }
}

function CreateAzureDevopsRepository {
    param (
        [Parameter(Mandatory)] [hashtable] $RepoConfiguration
    )
    [Argument]::AssertIsNotNull("RepoConfiguration", $RepoConfiguration)

    $repo = az repos show -r $RepoConfiguration.RepoName --org $RepoConfiguration.AzureDevOpsOrganizationURI --project $RepoConfiguration.AzureDevOpsProject
    if (! $?) {
        Write-Host "Creating repository..." -ForegroundColor Green
        $repo = az repos create --name $RepoConfiguration.RepoName --org $RepoConfiguration.AzureDevOpsOrganizationURI --project $RepoConfiguration.AzureDevOpsProject
    }
    else {
        Write-Host "Repository $($RepoConfiguration.RepoName) already exists." -ForegroundColor Blue
    }

    return $repo | ConvertFrom-Json -AsHashtable
}
function CloneRepo {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)] [hashtable] $RepoInfo,
        [Parameter(Mandatory)] [boolean] $UseSSH,
        [Parameter(Mandatory)] [boolean] $UsePAT
    )

    if (! $IsWindows) {
        $env:Temp = "/tmp";
    }
    $directory = Join-Path $env:Temp $(New-Guid)
    New-Item -Type Directory -Path $directory

    if ($UseSSH) {
        $domainGitUrl = $repoInfo.sshUrl
    }
    else {
        $domainGitUrl = $repoInfo.remoteUrl

        if ($UsePAT) {
           $domainGitUrl = AddPATGitDomain -DomainGitUrl $domainGitUrl
        }
    }

    git clone $domainGitUrl $directory
    
    return $directory[1]
}

function AddPATGitDomain {
    [cmdletbinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)] [string] $DomainGitUrl
    )

    $domainURI = [System.Uri]$DomainGitUrl

    $patAdded = $env:AZURE_DEVOPS_EXT_PAT + "@" + $domainURI.Host.Split(".")[0]

    $result = $domainURI.Scheme + "://" + ($domainURI.Host -Replace $domainURI.Host.Split(".")[0], $patAdded)

    $result = $result + $domainURI.AbsolutePath

    return $result 
}

function CreateAzDevOpsRepoApprovalPolicy {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)] [string] $Branch,
        [Parameter(Mandatory)] [hashtable] $RepoInfo,
        [Parameter(Mandatory)] [hashtable] $RepoConfiguration
    )
    [Argument]::AssertIsNotNull("RepoInfo", $RepoInfo)
    [Argument]::AssertIsNotNull("RepoConfiguration", $RepoConfiguration)

    Write-Host "Creating policy for approver count on branch $Branch" -ForegroundColor Green

    $result = az repos policy approver-count create --blocking true --branch $Branch --creator-vote-counts false --enabled true --minimum-approver-count $RepoConfiguration.MinimumApprovers --reset-on-source-push false --allow-downvotes false --repository-id $RepoInfo.id --org $RepoConfiguration.AzureDevOpsOrganizationURI --project $RepoConfiguration.AzureDevOpsProject

    $result | Write-Verbose
}

function CreateAzDevOpsRepoEnviorment {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)] [string] $Environment,
        [Parameter(Mandatory)] [hashtable] $RepoConfiguration
    )

    [Argument]::AssertIsNotNull("RepoConfiguration", $RepoConfiguration)

    $orgURI = $RepoConfiguration.AzureDevOpsOrganizationURI
    $project = $RepoConfiguration.AzureDevOpsProject

    Write-Host "Creating environment on branch $Environment" -ForegroundColor Green
    Write-Host "Project " $project -ForegroundColor Green
    Write-Host "Organization " $orgURI -ForegroundColor Green

    $envBody = @{
        name = $Environment
        description = "$Environment environment"
    }
    $infile = "envbody.json"
    Set-Content -Path $infile -Value ($envBody | ConvertTo-Json)
    az devops invoke `
        --area distributedtask --resource environments `
         --route-parameters project=$project --org $orgURI `
         --http-method POST --in-file $infile `
         --api-version "6.0-preview"
    rm $infile -f
    
    # $envBody = @{
    #     name = "qa"
    #     description = "My qa environment"
    # }
    #     $infile = "envbody.json"
    #     Set-Content -Path $infile -Value ($envBody | ConvertTo-Json)
    #     az devops invoke `
    #         --area distributedtask --resource environments `
    #         --route-parameters project=microsoft-devsquad --org https://dev.azure.com/a-fabiopadua0196 `
    #         --http-method POST --in-file $infile `
    #         --api-version "6.0-preview"
    #     rm $infile -f
}

function CreateAzDevOpsRepoCommentPolicy {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)] [string] $Branch,
        [Parameter(Mandatory)] [hashtable] $RepoInfo,
        [Parameter(Mandatory)] [hashtable] $RepoConfiguration
    )
    [Argument]::AssertIsNotNull("RepoInfo", $RepoInfo)
    [Argument]::AssertIsNotNull("RepoConfiguration", $RepoConfiguration)

    Write-Host "Creating policy for comment resolution on branch $Branch" -ForegroundColor Green

    $result = az repos policy comment-required create --blocking true --branch $Branch --enabled true --repository-id $RepoInfo.id --org $RepoConfiguration.AzureDevOpsOrganizationURI --project $RepoConfiguration.AzureDevOpsProject

    $result | Write-Verbose
}
function CreateAzDevOpsYamlPipelines {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)] [hashtable] $RepoConfiguration,
        [Parameter(Mandatory)] [string] $DefaultBranch
    )
    [Argument]::AssertIsNotNull("RepoConfiguration", $RepoConfiguration)

    foreach ($pipeline in $RepoConfiguration.Pipelines) {
        Write-Host "Creating AzDevOps Pipeline $($pipeline.Name)..." -ForegroundColor Green

        $result = az pipelines show --name "$($pipeline.Name)" --org $RepoConfiguration.AzureDevOpsOrganizationURI --project $RepoConfiguration.AzureDevOpsProject
        if (! $?){
            $result = az pipelines create --skip-first-run --branch "$DefaultBranch" --name "$($pipeline.Name)" --folder-path $RepoConfiguration.RepoName `
                                          --repository-type tfsgit --repository $RepoConfiguration.RepoName --yml-path $pipeline.SourceYamlPath `
                                          --org $RepoConfiguration.AzureDevOpsOrganizationURI --project $RepoConfiguration.AzureDevOpsProject
        }else{
            Write-Host "Pipeline '$($pipeline.Name)' already exists" -ForegroundColor Blue
        }

        $result | Write-Verbose
    }

}
function CreateAzDevOpsRepoBuildPolicy {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)] [string] $Branch,
        [Parameter(Mandatory)] [hashtable] $RepoInfo,
        [Parameter(Mandatory)] [hashtable] $RepoConfiguration
    )

    [Argument]::AssertIsNotNull("RepoInfo", $RepoInfo)
    [Argument]::AssertIsNotNull("RepoConfiguration", $RepoConfiguration)

    foreach ($pipeline in $RepoConfiguration.Pipelines) {
        if ($pipeline.BuildPolicy){
            Write-Host "Creating AzDevOps Build Policy for $($pipeline.Name)..." -ForegroundColor Green

            $pipelineId = az pipelines show --name "$($pipeline.Name)" --org $RepoConfiguration.AzureDevOpsOrganizationURI --project $RepoConfiguration.AzureDevOpsProject --query "id" -o tsv

            $displayName = "$($pipeline.BuildPolicy.Name)"

            $policyId = az repos policy list --repository-id $RepoInfo.id --branch $Branch `
                            --org $RepoConfiguration.AzureDevOpsOrganizationURI --project $RepoConfiguration.AzureDevOpsProject `
                            --query "[?settings.displayName=='$displayName'].id" -o tsv

            if (! $policyId) {
                $result = az repos policy build create --repository-id $RepoInfo.id --build-definition-id $pipelineId --display-name $displayName `
                                                    --branch $Branch --path-filter $pipeline.BuildPolicy.PathFilter `
                                                    --blocking true --enabled true  --queue-on-source-update-only true `
                                                    --manual-queue-only false --valid-duration 0 `
                                                    --org $RepoConfiguration.AzureDevOpsOrganizationURI --project $RepoConfiguration.AzureDevOpsProject
                $result | Write-Verbose
            }else{
                Write-Host "Build Policy '$displayName' already exists" -ForegroundColor Blue
            }
        }
    }
}
function SetupServiceConnection {
    [cmdletbinding()]
    param (
                [Parameter(Mandatory)] [hashtable] $Configuration,
        [Parameter(Mandatory)] [hashtable] $Environment,
        [Parameter(Mandatory)] [hashtable] $ServicePrincipal
    )

        [string]$organizationURI = "https://dev.azure.com/$($Configuration.azureDevOps.organization)"
        [string]$project = $Configuration.azureDevOps.project
        [string]$serviceConnectionName = $Environment.serviceConnectionName

    LogInfo -Message "Listing Azure DevOps service connections..."

    $serviceEndpointId = az devops service-endpoint list `
                --query "[?name=='$serviceConnectionName'].id" -o tsv `
                --organization $organizationURI `
                --project $project
    
    if (!$serviceEndpointId) {
        LogInfo -Message "No '$serviceConnectionName' service connection found. Creating..."

        $Pass = $ServicePrincipal.clientSecret

        if (! $Pass) {
            throw "Client Secret was not present in the request."
        }
        
        $env:AZURE_DEVOPS_EXT_AZURE_RM_SERVICE_PRINCIPAL_KEY = $Pass

        $subscription = Get-AzSubscription | Where-Object { $_.Id -eq $Environment.subscriptionId }
# Create a Service Connection
        $serviceEndpointId = az devops service-endpoint azurerm create `
            --azure-rm-service-principal-id $ServicePrincipal.clientId `
            --azure-rm-subscription-id $subscription.Id `
            --azure-rm-subscription-name $subscription.Name `
            --azure-rm-tenant-id $subscription.TenantId `
            --name $serviceConnectionName `
            --organization $organizationURI `
            --project $project `
            --query "id" -o tsv

                LogInfo -Message "Service connection '$serviceConnectionName' created."

# Function to convert manual connections to managed identity connections
function Convert-ServiceConnectionsToOIDC {
    param (
        [string]$OrganizationUrl,
        [string]$Project
    )

    $apiVersion = "7.1"
    $azdoResource = "499b84ac-1321-427f-aa17-267ca6975798" # Azure DevOps App ID (fixed)
    $OrganizationUrl = $OrganizationUrl.TrimEnd('/')

    Write-Host "Looking for manual service connections with Service Principal for conversion..."

    try {
        $allConnections = az rest `
            --resource $azdoResource `
            --method GET `
            --url "$OrganizationUrl/$Project/_apis/serviceendpoint/endpoints?includeDetails=true&api-version=$apiVersion" `
            | ConvertFrom-Json

        if (!$allConnections) {
            Write-Warning "No connection found. Check that the URL and project are correct."
            return
        }

        $eligibleConnections = $allConnections.value | Where-Object {
            $_.type -eq 'azurerm' -and
            $_.authorization.scheme -eq 'ServicePrincipal' -and
            $_.data.creationMode -eq 'Manual' -and
            $_.name -like 'spn-iac*'
        }

        if (!$eligibleConnections -or $eligibleConnections.Count -eq 0) {
            Write-Warning "No manual connection to Service Principal found to convert."
            return
        }

        foreach ($sc in $eligibleConnections) {
            Write-Host "Converting the connection '$($sc.name)' to Workload Identity Federation..."

            $sc.authorization.scheme = "WorkloadIdentityFederation"

            if ($sc.data.PSObject.Properties.Name -contains 'revertSchemeDeadline') {
                $sc.data.PSObject.Properties.Remove('revertSchemeDeadline')
            }

            $body = $sc | ConvertTo-Json -Depth 10 -Compress
            $putUrl = "$OrganizationUrl/$Project/_apis/serviceendpoint/endpoints/$($sc.id)?operation=ConvertAuthenticationScheme&api-version=$apiVersion"

            $result = az rest `
                --method PUT `
                --url $putUrl `
                --headers "Content-Type=application/json" `
                --body $body `
                --resource $azdoResource `
                | ConvertFrom-Json

            if ($result) {
                Write-Host "✅ '$($sc.name)' successfully converted!"
            } else {
                Write-Error "Failed to convert '$($sc.name)'"
            }
        }
    } catch {
        Write-Error "An error occurred during the conversion: $_"
    }
}


# Extract the name of organization
$organizationName = ([System.Uri]$OrganizationURI).Segments[-1].TrimEnd('/')

# Get App ID
$appId = az ad app list `
    --display-name "$($ServicePrincipal.displayName)" `
    --query "[0].appId" `
    -o tsv

Write-Host "Application ID: $appId"

# Get instanceId of Azure DevOps
$url = "$OrganizationURI/_apis/connectiondata?api-version=6.0-preview"
$pat = $env:AZURE_DEVOPS_EXT_PAT
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat"))
$headers = @{ Authorization = "Basic $base64AuthInfo" }

try {
    $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ContentType "application/json"
    $instanceId = $response.instanceId
} catch {
    Write-Error "Error to get Instance ID: $_"
    return
}

Write-Output "Instance ID: $instanceId"

# List environment
$ambientes = @("dev", "qa", "prod")
if (-not $global:AmbienteIndex) { $global:AmbienteIndex = 0 }
$areas = $ambientes[$global:AmbienteIndex]
$global:AmbienteIndex = ($global:AmbienteIndex + 1) % $ambientes.Length

Write-Host "Selected environment: $areas"

# Create federated credential
az ad app federated-credential create `
  --id $appId `
  --parameters "{
    `"name`": `"federated-devops.$areas`",
    `"issuer`": `"https://vstoken.dev.azure.com/$instanceId`",
    `"subject`": `"sc://$organizationName/$project/$serviceConnectionName`",
    `"audiences`": [ `"api://AzureADTokenExchange`" ]
  }"

Write-Host "Federated credential added successfully to the Service Principal."

# Update permission on the service endpoint
az devops service-endpoint update `
    --id $serviceEndpointId `
    --enable-for-all true `
    --organization $OrganizationURI `
    --project $project
    az devops service-endpoint update `
                --id $serviceEndpointId --enable-for-all true `
                --organization $organizationURI `
                --project $project

        LogInfo -Message "Access permission to all pipelines granted for '$serviceConnectionName' service connection."

Write-Host "⏳ Waiting for the service connection conversation start..."
Start-Sleep -Seconds 20
# Call the function to convert manual connections to managed identity
Convert-ServiceConnectionsToOIDC -OrganizationUrl $OrganizationURI -Project $project
# ✅ INSERÇÃO NO FIM: Exibir detalhes finais da configuração
Write-Host "`n✅ Finalização:"
    }
}
