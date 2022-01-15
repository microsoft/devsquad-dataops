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

    LogInfo -Message "Trying to get Service principal '$Name'."

	$servicePrincipal = Get-AzADServicePrincipal -DisplayName $Name

	if (! $servicePrincipal)
	{ 
        LogInfo -Message "Trying to create Service principal with DisplayName param with '$Name'"
		$servicePrincipal = New-AzADServicePrincipal -DisplayName $Name
		LogInfo -Message "Service principal '$Name' created."

        # $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($servicePrincipal.Secret)
        # $UnsecureSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

        # LogInfo -Message "Service principal secret '$UnsecureSecret'"

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
		
		Set-AzContext -Subscription $enviroment.subscriptionId

        AssignRoleIfNotExists -RoleName "Owner" -ObjectId $servicePrincipal.objectId -SubscriptionId $enviroment.subscriptionId

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

function AssignRoleIfNotExists 
{
    [cmdletbinding()]
	[OutputType([void])]
    param (
        [Parameter(Mandatory)] [string] $RoleName,
        [Parameter(Mandatory)] [string] $ObjectId,
        [Parameter(Mandatory)] [string] $SubscriptionId
    )

    $scope = "/subscriptions/$SubscriptionId"
    $roleAssignment = Get-AzRoleAssignment -ObjectId $ObjectId -RoleDefinitionName $RoleName -Scope $scope

    if (! $roleAssignment)
    {	
        # Remove retry loop after https://github.com/Azure/azure-powershell/issues/2286 is fixed
        $totalRetries = 30
        $retryCount = $totalRetries
        While ($True) {
            Try {
                New-AzRoleAssignment -ObjectId $ObjectId -RoleDefinitionName $RoleName -Scope $scope
                break
            }
            Catch {
                If ($retryCount -eq 0) {
                    LogError -Message "An error occurred: $($_.Exception)`n$($_.ScriptStackTrace)"
                    throw "The principal '$ObjectId' cannot be granted '$RoleName' role on the subscription '$SubscriptionId'. Please make sure the principal exists and try again later."
                }
                $retryCount--
                LogWarning -Message "The principal '$ObjectId' cannot be granted '$RoleName' role on the subscription '$SubscriptionId'. Trying again (attempt $($totalRetries - $retryCount)/$totalRetries)"
                Start-Sleep 10
            }
        }
        LogInfo -Message "Role '$RoleName' assigned to principal '$ObjectId' on the subscription '$SubscriptionId'."
    }
    else
    {
        LogWarning -Message "Role '$RoleName' was already assigned to principal '$ObjectId' oon the subscription '$SubscriptionId'."
    }
}
