Using module ./Common.psm1
Using module ./Logging.psm1

function ValidateConfigurationsDirectory {
    [cmdletbinding()]
	[OutputType([bool])]
    param(
        [Parameter(Mandatory)] [string] $ConfigurationsDirectory,
        [Parameter(Mandatory)] [string] $SchemaFile
    )

    if (-Not (Test-Path $ConfigurationsDirectory)) {
        throw "The $ConfigurationsDirectory directory does not exist!"
    }

    if (-Not (Test-Path $SchemaFile)) {
        throw "The $SchemaFile schema file does not exist!"
    }

	$ErrorActionPreference = "continue"

	Get-ChildItem $ConfigurationsDirectory -Exclude *template* -Recurse -File | 
	Foreach-Object {
		[bool]$validConfigFile = IsValidConfigurationFile -ConfigurationFile $_.FullName -SchemaFile $SchemaFile -Verbose:$VerbosePreference
		if (! $validConfigFile) {
			Write-Host "##vso[task.logissue type=error;sourcepath=$($_.FullName);linenumber=1;columnnumber=1;code=1;]Problems were found with this configuration file"
			$gotError = $true
		}else{
			Write-Verbose "$($_.FullName) is valid"
		}
	}
	
	$ErrorActionPreference = "stop"
	
	if ($gotError) {
		throw "Please check the logs, errors were found in your configuration files"
	}
}
function IsValidConfigurationFile {
    [cmdletbinding()]
	[OutputType([bool])]
    param(
        [Parameter(Mandatory)] [string] $ConfigurationFile,
        [Parameter(Mandatory)] [string] $SchemaFile
    )

    if (-Not (Test-Path $ConfigurationFile)) {
        throw "Config file '$ConfigurationFile' does not exist!"
    }
	else 
	{
		LogOk -Message "Config file '$ConfigurationFile' exists."
	}

    if (-Not (Test-Path $SchemaFile))
	{
        throw "Schema file '$SchemaFile' does not exist!"
    }
	else 
	{
		LogOk -Message "Schema file '$SchemaFile' exists."
	}

    return Get-Content -Path $ConfigurationFile -Raw | Test-Json -SchemaFile $SchemaFile
}
function IsValidConfigurationFileProperties {
    [cmdletbinding()]
	[OutputType([bool])]
    param(
        [Parameter(Mandatory)] [hashtable] $Configuration
    )

	$ErrorActionPreference = "continue"

	[bool]$validServicePrincipals = IsValidServicePrincipalAndServiceConnection -Environments $Configuration.environments -AzureDevOps $Configuration.azureDevOps
	[bool]$validAzureDevOps = IsValidAzureDevOps -AzureDevOps $Configuration.azureDevOps
	[bool]$validOutputTemplateFilePath = IsValidOutputTemplateFilePath -Path $Configuration.output.template
	
	$ErrorActionPreference = "stop"


	return $validServicePrincipals `
		-and $validAzureDevOps `
		-and $validOutputTemplateFilePath		
}
function IsValidServicePrincipalAndServiceConnection
{
	[cmdletbinding()]
	[OutputType([bool])]
    param(
		[Parameter(Mandatory)] [hashtable] $Environments,
        [Parameter(Mandatory)] [hashtable] $AzureDevOps
    )

	[bool]$validCredentials = $true

	foreach ($environmentItem in $Environments.Keys) {
		[hashtable]$environment = $Environments.Item($environmentItem)

		$servicePrincipal = Get-AzADServicePrincipal -DisplayName $environment.servicePrincipalName
		
		[string]$serviceConnectionName = $environment.serviceConnectionName
		[string]$organizationURI = "https://dev.azure.com/$($AzureDevOps.organization)"

		[string]$serviceConnectionId = az devops service-endpoint list `
			--query "[?name=='$serviceConnectionName'].id" -o tsv `
			--organization $organizationURI `
			--project $AzureDevOps.project

		if ($servicePrincipal -xor $serviceConnectionId)
		{
			$validCredentials = $false

			if ($servicePrincipal)
			{
				LogError -Message "The service principal '$($environment.servicePrincipalName)' already exists but the service connection '$serviceConnectionName' is missing. Please delete the service principal '$($environment.servicePrincipalName)' to continue."
			}
			else
			{
				LogError -Message "The service connection '$serviceConnectionName' already exists but the service principal '$($environment.servicePrincipalName)' is missing. Please delete the service connection '$serviceConnectionName' to continue."
			}
		}
	}

	return $validCredentials
}
function IsValidAzureDevOps
{
	[cmdletbinding()]
	[OutputType([bool])]
	param(
        [Parameter(Mandatory)] [hashtable] $AzureDevOps
    )

	[string]$organization = $AzureDevOps.organization
	[string]$project = $AzureDevOps.project
	[string]$organizationURI = "https://dev.azure.com/$organization"

	$validAzureDevOps = $(az devops project show --project $project --organization $organizationURI)

	if (! $validAzureDevOps)
	{
		LogError -Message "The Azure DevOps organization '$organization' and/or '$project' project does not exist."
		return $false
	}

	return $true
}
function IsValidOutputTemplateFilePath
{
	[cmdletbinding()]
	[OutputType([bool])]
	param(
        [Parameter(Mandatory)] [string] $Path
    )

	if (! (Test-Path $Path))
	{
		LogError -Message "The '$Path' path does not exist."
		return $false
	}

  	return $true
}