Using module ../modules/AzureDevOps.psm1
Using module ../modules/RepoOperations.psm1
Using module ../modules/Validation.psm1

[cmdletbinding()]
param(
    [Parameter(Mandatory)] $ConfigurationFile,
    [boolean] $UseSSH = $false,
    [boolean] $UsePAT = $true
)

$schemaFilePath = "./quickstart/schemas/dataops/config.schema.1.0.0.json"

$validConfigFile = IsValidConfigurationFile -ConfigurationFile $ConfigurationFile -SchemaFile $schemaFilePath -Verbose:$VerbosePreference

if (! $validConfigFile)
{
	throw "Invalid properties on the '$ConfigurationFile' configuration file."
}

$branches = 'develop','qa','main'
$config = LoadConfigurationFile -ConfigurationFile $ConfigurationFile -Verbose:$VerbosePreference

$repoInfo = CreateAzureDevopsRepository -RepoConfiguration $config.RepoConfiguration -Verbose:$VerbosePreference

$directory = CloneRepo -RepoInfo $repoInfo -UseSSH $UseSSH -UsePAT $UsePAT -Verbose:$VerbosePreference
ImportTemplateRepoToDomainRepo -Branches $branches -RepoConfiguration $config.RepoConfiguration -UsePAT $UsePAT -Directory $directory[0] -Verbose:$VerbosePreference

CreateAzDevOpsYamlPipelines -DefaultBranch $branches[0] -RepoConfiguration $config.RepoConfiguration -Verbose:$VerbosePreference

UpdateIaCParameters -Branch $branches[0] -Configuration $config -Directory $directory[0] -Verbose:$VerbosePreference

foreach ($branch in $branches)
{
    CreateAzDevOpsRepoApprovalPolicy -Branch $branch -RepoInfo $repoInfo -RepoConfiguration $config.RepoConfiguration -Verbose:$VerbosePreference
    CreateAzDevOpsRepoCommentPolicy -Branch $branch -RepoInfo $repoInfo -RepoConfiguration $config.RepoConfiguration -Verbose:$VerbosePreference
    CreateAzDevOpsRepoBuildPolicy -Branch $branch -RepoInfo $repoInfo -RepoConfiguration $config.RepoConfiguration -Verbose:$VerbosePreference
}

CreateAzDevOpsVariableGroups -RepoConfiguration $config.RepoConfiguration -Verbose:$VerbosePreference
