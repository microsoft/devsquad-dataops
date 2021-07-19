# Setup the Configuration File

1. Open the terminal, clone the source code of the lab and go to the `hol` directory.
   
    ```bash
    git clone https://holsetup:2je7narfoc2rusvewdjpfnlcn3pyponyrpsko3w5b6z26zj4wpoa@dev.azure.com/csu-devsquad/advworks-dataops/_git/ho
    cd hol
    ```

2. Execute the following command to create a new config file based on an existing template. Provide arguments to this setup based on the table below:

    ```bash
    # Be sure to execute this script under the hol directory
    ./quickstart/scripts/cloud-setup/Replace-TemplateArgs.ps1
    ```

|Argument|Description|Example|
|-----|-----------|-------|
|<_orgName_>|Azure DevOps organization name where you will execute the Hands-On Lab|_MyOrg_|
|<_projectName_>|Name of the existing project inside Azure DevOps where you will execute the Hands-On Lab|_MyDataOpsHOL_|
|<_projectAlias_>|An unique string with less than 8 characteres that will be used as part of your resource group names|_dataops_|
|<_subscriptionId_>|Azure Subscription ID where the resources will be deployed|_f7e5bb9e-0f98-4c5d-a5c1-a9154bf3cd61_|

- (_OPTIONAL_) If you are using this project as a Hands-On Lab, feel free to proceed to the next step of the quickstart. If you are using this project as a template for dataops, check [this additional documentation](./1b-create-prereqs-azure-advanced.md) that explains how you can do advanced configurations. 


## Next Step

* [Create the pre-required Azure resources](./2-create-prereqs-azure.md)
