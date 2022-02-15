Using module ../modules/Azure.psm1
Using module ../modules/RepoOperations.psm1
Using module ../modules/Validation.psm1
Using module ../modules/Logging.psm1

[cmdletbinding()]
param(
    [Parameter(Mandatory)] $ConfigurationFile
)

Write-Host "Cloud setup starting..."

BeginScope -Scope "Config file validation"

[string]$schemaFilePath = "./quickstart/schemas/cloud-setup/config.schema.1.0.0.json"

[bool]$validConfigFile = IsValidConfigurationFile -ConfigurationFile $ConfigurationFile -SchemaFile $schemaFilePath -Verbose:$VerbosePreference

if (! $validConfigFile)
{
  EndScope
	throw "Invalid properties on the '$ConfigurationFile' configuration file."
	exit 1
}

[hashtable]$config = LoadConfigurationFile -ConfigurationFile $ConfigurationFile -Verbose:$VerbosePreference
[bool]$validConfigFileProperties = IsValidConfigurationFileProperties -Configuration $config -Verbose:$VerbosePreference

if (! $validConfigFileProperties)
{
  EndScope
	throw "The '$ConfigurationFile' config file has invalid properties."
	exit 1
}

EndScope

[hashtable]$servicePrincipals = SetupServicePrincipals -Configuration $config -Verbose:$VerbosePreference
SetupEnvironments -Configuration $config -ServicePrincipals $servicePrincipals -Verbose:$VerbosePreference

#Save this password inside output hol file
$ServicePrincipalSecret = $ServicePrincipals[$config.servicePrincipals[0]].clientSecret

PublishOutputs -Configuration $config -ServicePrincipalSecret $ServicePrincipalSecret  -Verbose:$VerbosePreference

Write-Host "Done!"
