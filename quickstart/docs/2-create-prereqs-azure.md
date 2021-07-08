
# Create the pre-required Azure resources

Using [PowerShell Core](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1), run the following script to deploy the pre-required Azure resources:

```
az login

Connect-AzAccount

./quickstart/scripts/cloud-setup/Deploy-AzurePreReqs.ps1 -ConfigurationFile "quickstart/configs/cloud-setup/hol.json"
```

> The script validates the parameters of the config file created on the previous step.

The diagram below shows what Azure resources will be created after the execution of the script:

![Azure resources](./images/azure-prereqs-script.png)

## Next Step

* [Azure DevOps project setup](./3-azdo-setup.md)
