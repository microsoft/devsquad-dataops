# After the Hands-On Lab


1. Use the following code snippets to delete all you Azure resources:

    - Resource Groups:

        ```powershell
        # Use a filter to select resource groups by substring.
        # Replace <projectAlias> by the alias used to create your resource groups.
        $filter = 'rg-<projectAlias>-'
        
        # Find Resource Groups by Filter -> Verify Selection
        Get-AzResourceGroup | ? ResourceGroupName -match $filter | Select-Object ResourceGroupName
        
        # Async Delete ResourceGroups by Filter. Uncomment the following line if you understand what you are doing. :-)
        # Get-AzResourceGroup | ? ResourceGroupName -match $filter | Remove-AzResourceGroup -AsJob -Force
        ```

    - Service Principal:

        ```powershell
        # Find the service principal created for the lab
        Get-AzADServicePrincipal -DisplayName SP-<projectName>-DevTest
        
        # Delete the Service Principal. Uncomment the following line if you understand what you are doing. :-)
        # Get-AzADServicePrincipal -DisplayName SP-<projectName>-DevTest | Remove-AzADServicePrincipal
        ```

    - Azure DevOps Artifact Feed:
        - Delete the Artifact feed: `Artifacts` -> `lib-packages` -> `Feed Settings` -> `Delete Feed`
        - Purge the Artifact feed:
            Go to `Deleted Feeds` inside `Artifacts`. Select again `lib-packages` -> `Feed Settings` -> `Permanently Delete Feed`
    
    - Azure DevOps Project:
        - `Project Settings` -> `Overview` -> `Delete`