# Setup the Configuration File

1. Open the terminal, clone the source code of the lab and go to the `hol` directory.
   
    ```bash
    # URL Pattern: https://<anything>:<PAT>@dev.azure.com/<yourOrgName>/<yourProjectName>/_git/<yourRepoName>
    git clone https://holsetup:2je7narfoc2rusvewdjpfnlcn3pyponyrpsko3w5b6z26zj4wpoa@dev.azure.com/csu-devsquad/advworks-dataops/_git/hol
    cd hol
    ```

2. Create a new config file based on an existing template:

    ```bash
    cp quickstart/configs/cloud-setup/template.json quickstart/configs/cloud-setup/hol.json
    ```

3. Open the file `quickstart/configs/cloud-setup/hol.json` using your favorite editor and replace the following values:

|Argument|Description|Example|
|-----|-----------|-------|
|<_orgName_>|Azure DevOps organization name where you will execute the Hands-On Lab|_MyOrg_|
|<_projectName_>|Name of the existing project inside Azure DevOps where you will execute the Hands-On Lab|_MyDataOpsHOL_|
|<_projectAlias_>|An unique string with less than 8 characteres that will be used as part of your resource group names|_dataops_|
|<_subscriptionId_>|Azure Subscription ID where the resources will be deployed|_f7e5bb9e-0f98-4c5d-a5c1-a9154bf3cd61_|

3. You can also edit the subscriptions and service principals used by each one of the three environments: `dev`, `qa` and `prod`.

## Next Step

* [Create the pre-required Azure resources](./2-create-prereqs-azure.md)