Using module ../modules/AzureDevOps.psm1
Using module ../modules/RepoOperations.psm1
Using module ../modules/Validation.psm1

[cmdletbinding()]
param(
    [Parameter(Mandatory)] $ConfigurationFile,
    [boolean] $UseSSH = $true,
    [boolean] $UsePAT = $true
)

$schemaFilePath = "./quickstart/schemas/dataops/config.schema.1.0.0.json"

$validConfigFile = IsValidConfigurationFile -ConfigurationFile $ConfigurationFile -SchemaFile $schemaFilePath -Verbose:$VerbosePreference

if (! $validConfigFile)
{
	throw "Invalid properties on the '$ConfigurationFile' configuration file."
}

$config = LoadConfigurationFile -ConfigurationFile $ConfigurationFile -Verbose:$VerbosePreference

$repoInfo = CreateAzureDevopsRepository -RepoConfiguration $config.RepoConfiguration -Verbose:$VerbosePreference

$directory = CloneRepo -RepoInfo $repoInfo -UseSSH $UseSSH -UsePAT $UsePAT -Verbose:$VerbosePreference
ImportTemplateRepoToDomainRepo -RepoConfiguration $config.RepoConfiguration -UsePAT $UsePAT -Directory $directory[0] -Verbose:$VerbosePreference
UpdateIaCParameters -Configuration $config -Directory $directory[0] -Verbose:$VerbosePreference

CreateAzDevOpsRepoApprovalPolicy -RepoInfo $repoInfo -RepoConfiguration $config.RepoConfiguration -Verbose:$VerbosePreference
CreateAzDevOpsRepoCommentPolicy  -RepoInfo $repoInfo -RepoConfiguration $config.RepoConfiguration -Verbose:$VerbosePreference

CreateAzDevOpsYamlPipelines -RepoConfiguration $config.RepoConfiguration -Verbose:$VerbosePreference

CreateAzDevOpsRepoBuildPolicy -RepoInfo $repoInfo -RepoConfiguration $config.RepoConfiguration -Verbose:$VerbosePreference

CreateAzureDevOpsVariableGroup -VariableGroupName "dataops-iac-cd-output-dev"
CreateAzureDevOpsVariableGroup -VariableGroupName "dataops-iac-cd-output-qa"
CreateAzureDevOpsVariableGroup -VariableGroupName "dataops-iac-cd-output-prod"
CreateAzureDevOpsVariableGroup -VariableGroupName "lib-versions"
CreateAzureDevOpsVariable -VariableGroupName "lib-versions" -VariableName "MAJOR" -VariableValue "0"
CreateAzureDevOpsVariable -VariableGroupName "lib-versions" -VariableName "MINOR" -VariableValue "1"
CreateAzureDevOpsVariable -VariableGroupName "lib-versions" -VariableName "PATCH" -VariableValue "0"