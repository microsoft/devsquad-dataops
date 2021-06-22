class Argument {

    static [void] AssertIsNotNullOrEmpty([string] $paramName, [string] $paramValue) {
        if ([string]::IsNullOrWhiteSpace($paramValue)) {
            throw "Parameter $paramName is mandatory!"
        }
    }

    static [void] AssertIsNotNull([string] $paramName, [string] $paramValue) {
        if (-Not $paramValue) {
            throw "Parameter $paramName is null!"
        }
    }

    static [void] AssertIsMatch([string] $paramName, [string] $paramValue, [string] $regexPattern) {
        if (-Not ($paramValue -match $regexPattern)) {
            throw "Parameter $paramName value '$paramValue' does not match $regexPattern"
        }
    }
}

function LoadConfigurationFile {
    [cmdletbinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)] [string] $ConfigurationFile
    )
    [Argument]::AssertIsNotNullOrEmpty("ConfigurationFile", $ConfigurationFile)

    if (-Not (Test-Path $ConfigurationFile)) {
        throw "Configuration File: $ConfigurationFile does not exists!"
    }

    return (Get-Content -Path $ConfigurationFile | ConvertFrom-Json -AsHashtable)
}
