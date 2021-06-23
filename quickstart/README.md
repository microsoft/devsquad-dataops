# HOL Quickstart

## Setup the Configuration File

1. Open the terminal and create a new config file based on the template

```
cp quickstart/configs/cloud-setup/template.json quickstart/configs/cloud-setup/hol.json

```
2. Open the file with your favorite editor and replace the following values:

|Value|Description|Example|
|-----|-----------|-------|
|<_projectName_>|Name of the existing project inside Azure DevOps that will be used in the lab|_MyDataOpsHOL_|
|<_projectAlias_>|A string of 8 characteres that will be used as part of the name of for the Resource Groups|_dataops_|
|<_orgName_>|Azure DevOps organization name|_MyOrg_|
|<_subscriptionId_>|Azure Subscription ID where the resources will be deployed|_f7e5bb9e-0f98-4c5d-a5c1-a9154bf3cd61_|

3. Run a script to deploy the Azure pre-requisites using PowerShell Core. Note that this script will also validade the parameters of the config file.

```
pwsh

./quickstart/scripts/cloud-setup/Deploy-AzurePreReqs.ps1 -ConfigurationFile "quickstart/configs/cloud-setup/hol.json"

```

4. Now set the environment variable ```$env:AZURE_DEVOPS_EXT_PAT``` with a [PAT (Personal Access Token)](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page) with **Code (read)** [scope](https://docs.microsoft.com/en-us/azure/devops/integrate/get-started/authentication/oauth?view=azure-devops#scopes) to enable the script to connect to the Azure DevOps containing the files and instructions of the lab. It is required because if will clone the repository to the new Azure DevOps project that will be used for this lab.

```
$env:AZURE_DEVOPS_EXT_PAT="<my pat goes here>"
```

5. Run the script to clone the repo, create the pipeline and service connections inside the new Azure DevOps. (*) Note that the file name is the one inside the output directory and the name is the same name of the _projectName_ that was replaced in the first config file.

```
./quickstart/scripts/dataops/Deploy-AzureDevOps.ps1 -ConfigurationFile "./quickstart/outputs/hol.json" 

```
