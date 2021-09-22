param(
    [Parameter(Mandatory)] [string] [ValidateSet("dev", "qa", "prod", "sandbox")] $Environment,
    [Parameter(Mandatory)] [string] $Version,
    [Parameter(Mandatory)] [string] $Location,
    [Parameter(Mandatory)] [string] $SolutionName,
    [string] $SolutionTemplateFile = "./infrastructure-as-code/infrastructure/azuredeploy.json",
    [string] $SolutionParametersFile = "./infrastructure-as-code/infrastructure/parameters/parameters.$Environment.json",
    [string] $VersionDescription = "",
    [string] $VersionBuildId = "",
    [string] $VersionAuthor = ""
)

[string] $TemplateSpecRgName = "rg-$SolutionName-template-specs"

Write-Host "Start planning $SolutionName ($Version) on $Environment environment at $Location" -ForegroundColor Green

Write-Host "Getting resource group $TemplateSpecRgName" -ForegroundColor Green
$rg = Get-AzResourceGroup -Name $TemplateSpecRgName

if ($Environment -eq "prod"){
    Write-Host "Checking if template spec $TemplateSpecRgName $Version already exists..." -ForegroundColor Green
    $template = Get-AzTemplateSpec  -ResourceGroupName $TemplateSpecRgName -Name $SolutionName -Version $Version -ErrorAction SilentlyContinue
}

if (!$template) {
    Write-Host "Publishing template spec..." -ForegroundColor Green
    
    $metadata = @{
        BuildId = $VersionBuildId
        Author = $VersionAuthor
    }

    $template = New-AzTemplateSpec -Name $SolutionName -Version $Version -ResourceGroupName $TemplateSpecRgName -Location $rg.Location -TemplateFile $SolutionTemplateFile -VersionDescription "$VersionDescription" -Tag $metadata -Force
}

Write-Host "Previewing template deployment changes..." -ForegroundColor Green
New-AzDeployment -Location $Location -TemplateSpecId $template.Versions.Id -Name $Version `
    -TemplateParameterFile $SolutionParametersFile -SkipTemplateParameterPrompt -WhatIf