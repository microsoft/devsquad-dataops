
# Create the pre-required Azure resources

## Create a Personal Access Token (PAT)

An environment variable called `AZURE_DEVOPS_EXT_PAT` that stores a [PAT (Personal Access Token)](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page) with **Full Access** is required to allow the next script to connect to the new Azure DevOps project and deploy all the resources.

To do so, create the PAT on your new Azure DevOps project then run the following command:

```
$env:AZURE_DEVOPS_EXT_PAT="<my pat goes here>"
```

## Connect to Azure account

A PowerShell command execution is required to connect to Azure with your authenticated account.

If you are running PowerShell on **Windows**, simply run:

```
Connect-AzAccount
```

Otherwise, run the same command with the `-UseDeviceAuthentication` flag enabled:

```
Connect-AzAccount -UseDeviceAuthentication
```

## Run the script

Using [PowerShell Core](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1), run the following script to deploy the pre-required Azure resources:

```
./quickstart/scripts/cloud-setup/Deploy-AzurePreReqs.ps1 -ConfigurationFile "quickstart/configs/cloud-setup/hol.json"
```

> The script validates the parameters of the config file created on the previous step.

The diagram below shows what Azure resources will be created after the execution of the script:

![Azure resources](./images/azure-prereqs-script.png)

## Next Step

* [Prepare your Azure DevOps project](./3-azdo-setup.md)
