Using module ../modules/Validation.psm1

[cmdletbinding()]
param(
    [Parameter()] $ConfigurationsDirectory
)

[string]$schemaFilePath = "./schemas/dataops/config.schema.1.0.0.json"
[string]$ConfigurationsDirectory = "./configs/dataops/"

ValidateConfigurationsDirectory -ConfigurationsDirectory $ConfigurationsDirectory -SchemaFile $schemaFilePath -Verbose:$VerbosePreference