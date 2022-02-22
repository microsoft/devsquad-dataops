Using module ./Common.psm1
Using module ./Logging.psm1

function ImportTemplateRepoToDomainRepo {
    param (
        [Parameter(Mandatory)] [hashtable] $RepoConfiguration,
        [Parameter(Mandatory)] [string[]] $Branches,
        [Parameter(Mandatory)] [string] $Directory
    )
    [Argument]::AssertIsNotNull("RepoConfiguration", $RepoConfiguration)

    Write-Host "Importing Template..." -ForegroundColor Green

    Set-Location $Directory

	$templateGitUrl = $RepoConfiguration.TemplateGitUrl
	
    git remote add template $templateGitUrl
    git fetch template
    git merge remotes/template/main

	foreach ($branch in $branches){
		git push -u origin HEAD:$branch
	}
	
    Set-Location -
}

function UpdateIaCParameters {
    param (
        [Parameter(Mandatory)] [string] $Branch,
        [Parameter(Mandatory)] [hashtable] $Configuration,
        [Parameter(Mandatory)] [string] $Directory
    )
    [Argument]::AssertIsNotNull("Configuration", $Configuration)

    Write-Host "Updating IaC parameters..." -ForegroundColor Green

    Set-Location $Directory

	git checkout $Branch

	BeginScope -Scope "IaC parameters"

	$ServicePrincipalSecret = $Configuration.Project.ServicePrincipalSecret

	ReplaceTemplateTokens -Configuration $Configuration -RemoveInput `
		-InputFile infrastructure-as-code/infrastructure/parameters/parameters.dev.template.json `
		-OutputFile infrastructure-as-code/infrastructure/parameters/parameters.dev.json `
		-ServicePrincipalSecret $ServicePrincipalSecret `

	ReplaceTemplateTokens -Configuration $Configuration -RemoveInput `
		-InputFile infrastructure-as-code/infrastructure/parameters/parameters.qa.template.json `
		-OutputFile infrastructure-as-code/infrastructure/parameters/parameters.qa.json `
		-ServicePrincipalSecret $ServicePrincipalSecret `

	ReplaceTemplateTokens -Configuration $Configuration -RemoveInput `
		-InputFile infrastructure-as-code/infrastructure/parameters/parameters.prod.template.json `
		-OutputFile infrastructure-as-code/infrastructure/parameters/parameters.prod.json `
		-ServicePrincipalSecret $ServicePrincipalSecret `
	
	ReplaceTemplateTokens -Configuration $Configuration -RemoveInput `
		-InputFile azure-pipelines/databricks/databricks-lib-cd.template.yml `
		-OutputFile azure-pipelines/databricks/databricks-lib-cd.yml `
	
	ReplaceTemplateTokens -Configuration $Configuration -RemoveInput `
		-InputFile azure-pipelines/variable.environment.template.yml `
		-OutputFile azure-pipelines/variable.environment.yml `
		
	EndScope

	git add .
	git commit -m "Update template parameters"
    git push -u origin HEAD:$Branch

    Set-Location -
}

function PublishOutputs {
    param(
        [Parameter(Mandatory)] [hashtable] $Configuration,
		[Parameter(Mandatory)] [string] $ServicePrincipalSecret
    )
	
	BeginScope -Scope "Outputs"

	Write-Host "Input file " $Configuration.output.template
	Write-Host "Output file " $Configuration.output.file

	ReplaceTemplateTokens `
		-Configuration $Configuration `
		-InputFile $Configuration.output.template `
		-OutputFile $Configuration.output.file `
		-ServicePrincipalSecret $ServicePrincipalSecret `

	EndScope
}

function ReplaceTemplateTokens {
	[cmdletBinding()]
	param(
		[Parameter(Mandatory)] [hashtable] $Configuration,
		[Parameter(Mandatory)] [string] $InputFile,
		[Parameter(Mandatory)] [string] $OutputFile,
		[string] $ServicePrincipalSecret,
		[string] $StartTokenPattern = '<',
		[string] $EndTokenPattern = '>',
		[switch] $RemoveInput
	)

	CleanFileIfExists -File $OutputFile

	[int]$totalTokens = 0

	Write-Host "Input File '$InputFile'"

	(Get-Content $InputFile) | ForEach-Object {
		$line = $_
		$tokens = GetTokens -Line $line -StartTokenPattern $StartTokenPattern -EndTokenPattern $EndTokenPattern
		$totalTokens += $tokens.Count

		foreach ($token in $tokens) {

			[string]$configPropertyName = $token -replace "$($StartTokenPattern)|$($EndTokenPattern)", ''

			if ( $configPropertyName -eq "serviceprincipal.secret") {
				Write-Verbose "Replacing '$token' token by '$ServicePrincipalSecret'"
				$line = $line -replace "$token", "$ServicePrincipalSecret"
			}
			else {
				[string]$tokenValue = Invoke-Expression -Command "`$Configuration.$configPropertyName"
				Write-Verbose "Replacing '$token' token by '$tokenValue'"
				$line = $line -replace "$token", "$tokenValue"
			}
		}

		$line | Out-File -Append -FilePath $OutputFile
	}

	if ($RemoveInput) {
		Remove-Item $InputFile
	}

	Write-Host "Done! ($totalTokens tokens replaced successfully)"
}

function CleanFileIfExists
{
	[cmdletbinding()]
    param(
		[Parameter(Mandatory)] [string] $File
    )

	if (Test-Path -Path $File) {
		Write-Verbose "Clearing file $File"
		Clear-Content -Path $File
	}
	else
	{
		[string]$folder = Split-Path -parent $File
		New-Item $folder -Type Directory
	}
}

function GetTokens
{
	[cmdletbinding()]
    param(
		[Parameter(Mandatory)] [AllowEmptyString()] [string] $Line,
        [Parameter(Mandatory)] [string] $StartTokenPattern,
		[Parameter(Mandatory)] [string] $EndTokenPattern
    )

	[string]$pattern = "$($StartTokenPattern).+?$($EndTokenPattern)"

	return $Line 
		| Select-String -Pattern $pattern -AllMatches 
		| Select-Object -ExpandProperty Matches 
		| Foreach-Object {$_.Groups[0].Value}
}
