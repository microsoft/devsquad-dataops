function BeginScope
{
    param (
        [Parameter(Mandatory)] [string] $Scope
    )

	Write-Host "##[group]$Scope"
}

function EndScope
{
	Write-Host "##[endgroup]"
}

function LogInfo
{
    param (
        [Parameter(Mandatory)] [string] $Message
    )

	Write-Host "##[command]$Message"
}

function LogWarning
{
    param (
        [Parameter(Mandatory)] [string] $Message
    )

	Write-Host "##[warning]$Message"
}

function LogOk
{
    param (
        [Parameter(Mandatory)] [string] $Message
    )

	Write-Host "##[section]$Message"
}

function LogError
{
    param (
        [Parameter(Mandatory)] [string] $Message
    )

	Write-Host "##[error]$Message"
}
