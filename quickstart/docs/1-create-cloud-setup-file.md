# Setup the Configuration File

1. Open the terminal and create a new config file based on an existing template:

    ```bash
    cd hol
    ./quickstart/scripts/cloud-setup/Replace-TemplateArgs.ps1 -projectName "<myProjectName>" -projectAlias "<myProjectAlias>" -orgName "<myOrgName>" -subscriptionId "<mySubscriptionId>"
    ```

    - *Observation: Be sure to execute command above under the `./hol` directory*

2. Open the file `quickstart/configs/cloud-setup/hol.json` using your favorite editor and replace the following values:

|Value|Description|Example|
|-----|-----------|-------|
|<_projectName_>|Name of the existing project inside Azure DevOps that will be used in the lab|_MyDataOpsHOL_|
|<_projectAlias_>|A string of 8 characteres that will be used as part of the name of for the Resource Groups|_dataops_|
|<_orgName_>|Azure DevOps organization name|_MyOrg_|
|<_subscriptionId_>|Azure Subscription ID where the resources will be deployed|_f7e5bb9e-0f98-4c5d-a5c1-a9154bf3cd61_|

## Next Step

* [Create the pre-required Azure resources](./2-create-prereqs-azure.md)
