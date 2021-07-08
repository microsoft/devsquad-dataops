# Before Hands-On Lab Quickstart

## Pre-requisites

1. Create a new [Azure Azure DevOps Project](https://docs.microsoft.com/en-us/azure/devops/organizations/projects/create-project?view=azure-devops&tabs=preview-page).

2. [Install](https://docs.microsoft.com/en-us/azure/devops/marketplace/install-extension?view=azure-devops&tabs=browser) the [GitTools extension](https://marketplace.visualstudio.com/items?itemName=gittools.gittools&targetId=0d8e54d4-e229-47bd-9dc5-9be0f116a5c0&utm_source=vstsproduct&utm_medium=ExtHubManageList) in the Organization level of the new Azure DevOps Project

3. Authorize the project **Build Service** to be an Administrator of Variable Groups:

    - Select **Library** under **Pipelines**:

        ![](docs/images/quickstart-buildservice-1.png)

    - Click the **Security** button:

        ![](docs/images/quickstart-buildservice-2.png)

    - Make sure the **Build Service** has the **Administrator** role:

        ![](docs/images/quickstart-buildservice-3.png)

        > In case the Build Service user is not present on this list, click on `+ Add` and search for `projectName Build Service`, assigning the `Administrator` role.

4. Make sure the Organization where the project is created in the Azure DevOps is [connected with the Azure Active Directory](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/connect-organization-to-azure-ad?view=azure-devops
) of the Azure Subscription that will be used in the lab.

## Setup the Configuration File

1. Open the terminal and create a new config file based on the template:

    ```
    cp quickstart/configs/cloud-setup/template.json quickstart/configs/cloud-setup/hol.json
    ```

2. Open the file `quickstart/configs/cloud-setup/hol.json` using your favorite editor and replace the following values:

    |Value|Description|Example|
    |-----|-----------|-------|
    |<_projectName_>|Name of the existing project inside Azure DevOps that will be used in the lab|_MyDataOpsHOL_|
    |<_projectAlias_>|A string of 8 characteres that will be used as part of the name of for the Resource Groups|_dataops_|
    |<_orgName_>|Azure DevOps organization name|_MyOrg_|
    |<_subscriptionId_>|Azure Subscription ID where the resources will be deployed|_f7e5bb9e-0f98-4c5d-a5c1-a9154bf3cd61_|

## Create the pre-required Azure resources

Using [PowerShell Core](https://docs.microsoft.com/en-us/powershell/scripting/insta
ll/installing-powershell?view=powershell-7.1), run the following script to deploy the pre-required Azure resources:

```
az login

Connect-AzAccount

./quickstart/scripts/cloud-setup/Deploy-AzurePreReqs.ps1 -ConfigurationFile "quickstart/configs/cloud-setup/hol.json"
```

> The script validates the parameters of the config file created on the previous step.

The diagram below shows what Azure resources will be created after the execution of the script:

![Azure resources](./docs/images/azure-prereqs-script.png)

## Create the environment variables

An environment variable called `AZURE_DEVOPS_EXT_PAT_TEMPLATE` that stores a [PAT (Personal Access Token)](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page) with **Code (read)** [scope](https://docs.microsoft.com/en-us/azure/devops/integrate/get-started/authentication/oauth?view=azure-devops#scopes) is required to allow you to clone this repository to your new Azure DevOps project that will be used for this lab. To do so, run the following command:

```
$env:AZURE_DEVOPS_EXT_PAT_TEMPLATE="<my pat goes here>"
```

Another environment variable called `AZURE_DEVOPS_EXT_PAT` that also stores a [PAT (Personal Access Token)](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page), but now with **Full Access** is required to allow the next script to connect to the new Azure DevOps project and deploy all the resources. To do so, run the following command:

```
$env:AZURE_DEVOPS_EXT_PAT="<my pat goes here>"
```

## Azure DevOps project setup

Run the following script to clone the `hol` repo, create the pipelines and service connections inside your new Azure DevOps.

>  Note the file name is the one inside the output directory and the name is the same name of the _projectName_ that was replaced in the first config file.

```
./quickstart/scripts/dataops/Deploy-AzureDevOps.ps1 -ConfigurationFile "./quickstart/outputs/hol.json" -UsePAT $true
```
