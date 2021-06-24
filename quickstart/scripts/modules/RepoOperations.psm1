Using module ./Common.psm1
Using module ./Logging.psm1

function ImportTemplateRepoToDomainRepo {
    param (
        [Parameter(Mandatory)] [hashtable] $RepoConfiguration,
        [Parameter(Mandatory)] [string] $Directory,
		[Parameter(Mandatory)] [boolean] $UsePAT
    )
    [Argument]::AssertIsNotNull("RepoConfiguration", $RepoConfiguration)

    Write-Host "Importing Template..." -ForegroundColor Green

    Set-Location $Directory

	$templateGitUrl = $RepoConfiguration.TemplateGitUrl
	if ($UsePAT) {
		$templateGitUrl = $templateGitUrl -replace "(?<=https://\s*).*?(?=\s*@)", $env:AZURE_DEVOPS_EXT_PAT
	}

    git remote add template $templateGitUrl
    git fetch template
    git merge remotes/template/main
    git branch -M $RepoConfiguration.DefaultBranchName
    git push -u origin $RepoConfiguration.DefaultBranchName
	
    Set-Location -
}

function UpdateIaCParameters {
    param (
        [Parameter(Mandatory)] [hashtable] $Configuration,
        [Parameter(Mandatory)] [string] $Directory
    )
    [Argument]::AssertIsNotNull("Configuration", $Configuration)

    Write-Host "Updating IaC parameters..." -ForegroundColor Green

    Set-Location $Directory

	BeginScope -Scope "IaC parameters"

	ReplaceTemplateTokens `
		-Configuration $Configuration `
		-InputFile infrastructure-as-code/infrastructure/parameters/parameters.dev.template.json `
		-OutputFile infrastructure-as-code/infrastructure/parameters/parameters.dev.json

	ReplaceTemplateTokens `
		-Configuration $Configuration `
		-InputFile infrastructure-as-code/infrastructure/parameters/parameters.qa.template.json `
		-OutputFile infrastructure-as-code/infrastructure/parameters/parameters.qa.json 

	ReplaceTemplateTokens `
		-Configuration $Configuration `
		-InputFile infrastructure-as-code/infrastructure/parameters/parameters.prod.template.json `
		-OutputFile infrastructure-as-code/infrastructure/parameters/parameters.prod.json 
		
	EndScope

	git add infrastructure-as-code/infrastructure/parameters/parameters.dev.json
	git add infrastructure-as-code/infrastructure/parameters/parameters.qa.json
	git add infrastructure-as-code/infrastructure/parameters/parameters.prod.json

	git commit -m "Update IaC paramaters."

    git push -u origin $RepoConfiguration.DefaultBranchName
	
    Set-Location -
}

function PublishOutputs {
    param(
        [Parameter(Mandatory)] [hashtable] $Configuration
    )
	
	BeginScope -Scope "Outputs"

	ReplaceTemplateTokens `
		-Configuration $Configuration `
		-InputFile $Configuration.output.template `
		-OutputFile $Configuration.output.file `
	
	EndScope
}

function ReplaceTemplateTokens {
	[cmdletBinding()]
	param(
		[Parameter(Mandatory)] [hashtable] $Configuration,
		[Parameter(Mandatory)] [string] $InputFile,
		[Parameter(Mandatory)] [string] $OutputFile,
		[string] $StartTokenPattern = '<',
		[string] $EndTokenPattern = '>'
	)

	CleanFileIfExists -File $OutputFile

	[int]$totalTokens = 0

	(Get-Content $InputFile) | ForEach-Object {
		$line = $_
		$tokens = GetTokens -Line $line -StartTokenPattern $StartTokenPattern -EndTokenPattern $EndTokenPattern
		$totalTokens += $tokens.Count

		foreach ($token in $tokens) {
			[string]$configPropertyName = $token -replace "$($StartTokenPattern)|$($EndTokenPattern)", ''
			[string]$tokenValue = Invoke-Expression -Command "`$Configuration.$configPropertyName"
			
			Write-Verbose "Replacing '$token' token by '$tokenValue'"
			$line = $line -replace "$token", "$tokenValue"
		}

		$line | Out-File -Append -FilePath $OutputFile
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
