# Prepare your Azure DevOps project

## Create an Artifact Feed

An artifact feed is required on the lab for publishing Python libraries with versioning.
On your Azure DevOps project, go to the `Artifacts` section -> `Create Feed`, then set the name as `lib-packages`:

![Artifact feed](./images/create-artifact-feed.png)

## Project setup

Initial setup of git configuration and environment variables:

```powershell
# You don't need to change any of the following values below
git config --global user.email "hol@microsoft.com"
git config --global user.name "HOL Setup User"
$env:AZURE_DEVOPS_EXT_PAT_TEMPLATE="2je7narfoc2rusvewdjpfnlcn3pyponyrpsko3w5b6z26zj4wpoa"
```

Run the following script to clone the `hol` repo, create the pipelines and service connections inside your new Azure DevOps.

>  Note the file name is the one inside the output directory and the name is the same name of the _projectName_ that was replaced in the first config file.

```powershell
./quickstart/scripts/dataops/Deploy-AzureDevOps.ps1 -ConfigurationFile "./quickstart/outputs/hol.json" -UsePAT $true
```

- (Optional) If you are using this project as a Hands-On Lab, feel free to proceed to the next step of the quickstart.If you are using this project as a template for dataops, check [this documentation](./3b-azdo-setup-advanced.md) for understanding more details about the `AZURE_DEVOPS_EXT_PAT_TEMPLATE` environment variable. 

## Next Step

* [Create Azure Databricks secrets scope for all environments](./4-create-databricks-secrets-scope.md)
