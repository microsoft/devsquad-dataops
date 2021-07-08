# Create Databricks secrets scope

After completing the [Preparing your Azure DevOps project](./3-azdo-setup.md) step, make sure the Infrastructure as Code CD pipeline `dataops-iac-cd` is executed successfully.
Then, run the PowerShell script located at `infrastructure-as-code/scripts` to create the Databricks secrets scope for each environment:

```
./DatabricksSecrets.ps1 `
  -ClientID "<client_id>" `
  -ClientSecret "<client_secret>" `
  -DataResourceGroup "<data_resource_group_name>" `
  -ComputeResourceGroup "<compute_resource_group_name>" `
  -KeyVaultName "<kv_name>" `
  -DataLakeName "<adls_name>" `
  -DatabricksName "<databricks_name>"
```
