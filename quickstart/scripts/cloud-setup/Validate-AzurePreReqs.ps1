Using module ../modules/Validation.psm1

[cmdletbinding()]
param(
    [Parameter(Mandatory)] $ConfigurationsDirectory
)

[string]$schemaFilePath = "./quickstart/schemas/cloud-setup/config.schema.1.0.0.json"

ValidateConfigurationsDirectory -ConfigurationsDirectory $ConfigurationsDirectory -SchemaFile $schemaFilePath -Verbose:$VerbosePreference
