# Create Databricks secrets scope

## Infrastructure Pipeline

After completing the [Preparing your Azure DevOps project](./3-azdo-setup.md) step, make sure the Infrastructure as Code CD pipeline `dataops-iac-cd` is executed successfully when triggered from the `develop` branch.

Right after, open a PR from `develop` to `qa` to promote the code changes to the QA environment. Please wait again for the creation of the QA infrastructure.
Repeat the process one last time, opening a PR from `qa` to `main` to promote the code changes to the PROD environment. Please wait again for the creation of the PROD infrastructure.

## Databricks Secrets Scope

Then, run the PowerShell script located at `infrastructure-as-code/scripts` to create the Databricks secrets scope for **each environment**:

```
$clientSecret = ConvertTo-SecureString -AsPlainText

./DatabricksSecrets.ps1 `
  -ClientID "<client_id>" `
  -ClientSecret $clientSecret `
  -DataResourceGroup "<data_resource_group_name>" `
  -ComputeResourceGroup "<compute_resource_group_name>" `
  -KeyVaultName "<kv_name>" `
  -DataLakeName "<adls_name>" `
  -DatabricksName "<databricks_name>"
```
