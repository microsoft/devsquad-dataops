Using module ./Common.psm1
Using module ./AzureDevOps.psm1
Using module ./Logging.psm1

function SetupServicePrincipals
{
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)] [hashtable] $Configuration
    )

	BeginScope -Scope "Service Principals"

    $servicePrincipals = @{}

    foreach ($principalName in $Configuration.servicePrincipals)
	{
		$servicePrincipal = CreateOrGetServicePrincipal -Name $principalName

        $servicePrincipals += @{        
            $servicePrincipal.DisplayName = @{
                "objectId" = $servicePrincipal.Id
                "clientId" = $servicePrincipal.ApplicationId
				"displayName" = $servicePrincipal.DisplayName
                "clientSecret" = $servicePrincipal.Secret
            }
        }
    }

	EndScope
	
    return $servicePrincipals
}

function CreateOrGetServicePrincipal
{
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)] [string] $Name
    )

	$servicePrincipal = Get-AzADServicePrincipal -DisplayName $Name

	if (! $servicePrincipal)
	{ 
		$servicePrincipal = New-AzADServicePrincipal -DisplayName $Name -Role "Owner"
		LogInfo -Message "Service principal '$Name' created."
	}
	else
	{
		LogWarning -Message "Service principal $Name' already exists."
	}

	return $servicePrincipal
}

function SetupEnvironments {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)] [hashtable] $Configuration,
        [Parameter(Mandatory)] [hashtable] $ServicePrincipals
    )

    foreach ($envKey in $Configuration.environments.keys) 
	{
		BeginScope -Scope "Environment: $envKey"
		
		$enviroment = $Configuration.environments[$envKey]
		$servicePrincipal = $ServicePrincipals[$enviroment.servicePrincipalName]
		
		# Select the subscription
		Set-AzContext -Subscription $enviroment.subscriptionId

        SetupResourceGroups -Environment $envKey -Configuration $Configuration
		SetupServiceConnection -Environment $enviroment -ServicePrincipal $servicePrincipal -Configuration $Configuration

		EndScope
	}
}

function SetupResourceGroups {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)] [string] $Environment,
        [Parameter(Mandatory)] [hashtable] $Configuration
    )

    foreach ($resourceType in @('data','compute','ml','network')) 
	{
		$SolutionName =	$Configuration.project.alias
		CreateOrGetResourceGroup `
			-Name "rg-$SolutionName-$resourceType-$Environment" `
			-Location $Configuration.project.location
	}

	CreateOrGetResourceGroup `
		-Name "rg-$SolutionName-template-specs" `
		-Location $Configuration.project.location

}

function CreateOrGetResourceGroup 
{
    [cmdletbinding()]
	[OutputType([hashtable])]
    param (
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [string] $Location
    )

    $resourceGroup = Get-AzResourceGroup -Name $Name -ErrorAction Ignore

    if (!$resourceGroup)
	{
        $resourceGroup = New-AzResourceGroup -Name $Name -Location $Location
		LogInfo -Message "Resource group '$Name' created."
    }
    else 
    {
		LogWarning -Message "Resource group '$Name' already exists."
    }

	return $resourceGroup
}
