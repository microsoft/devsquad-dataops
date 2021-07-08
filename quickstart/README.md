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

## Getting Started

* [Step 1: Setup the Configuration File](./docs/1-setup-config-file.md)
* [Step 2: Create the pre-required Azure resources](./docs/2-create-prereqs-azure.md)
* [Step 3: Azure DevOps project setup](./docs/3-azdo-setup.md)
