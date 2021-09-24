# After the Hands-On Lab


1. Execute the following script to delete all your Azure resources created on this Hands-On Lab.

    ```poweershell
    ./quickstart/scripts/cloud-setup/Delete-AzureResources.ps1
    ```

    - You will be prompted to provide your `projectName` and `projectAlias`:


        |Argument|Description|
        |-----|-----------|
        |_projectName_|Name of the Azure DevOps project used for this Hands-On Lab|
        |_projectAlias_|An unique string with less than 8 characteres that was used as part of your resource group names|


2. Open [Azure DevOps](https://dev.azure.com) and delete the following resources:

    - Azure DevOps Artifact Feed:
        - Delete the Artifact feed: `Artifacts` -> `lib-packages` -> `Feed Settings` -> `Delete Feed`
        - Purge the Artifact feed:
            Go to `Deleted Feeds` inside `Artifacts`. Select again `lib-packages` -> `Feed Settings` -> `Permanently Delete Feed`
    
    - Azure DevOps Project:
        - `Project Settings` -> `Overview` -> `Delete`