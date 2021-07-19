## (Optional) Create the environment variables

An environment variable called `AZURE_DEVOPS_EXT_PAT_TEMPLATE` that stores a [PAT (Personal Access Token)](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page) with **Code (read)** [scope](https://docs.microsoft.com/en-us/azure/devops/integrate/get-started/authentication/oauth?view=azure-devops#scopes) is required to allow you to clone this repository to your new Azure DevOps project that will be used for this lab.

To do so, create a PAT on the `advworks-dataops` project (not on your new Azure DevOps project) then run the following command:

``` powershell
$env:AZURE_DEVOPS_EXT_PAT_TEMPLATE="<my pat goes here>
```