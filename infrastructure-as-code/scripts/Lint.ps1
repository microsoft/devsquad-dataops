param(
    [string] $TtkFolder = "./ttk",
    [string] $SolutionTemplateFolder = "./infrastructure"
)

$ErrorActionPreference = "Continue"

Import-Module "$TtkFolder/arm-ttk/arm-ttk.psd1"

$testOutput = @(Test-AzTemplate -TemplatePath $SolutionTemplateFolder)
$testOutput

if ($testOutput | ? { $_.Errors }) {
    Write-Host "##vso[task.logissue type=warning;]Linter has found some problems."
}
