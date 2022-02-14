![Microsoft Cloud Workshops](https://github.com/Microsoft/MCW-Template-Cloud-Workshop/raw/main/Media/ms-cloud-workshop.png "Microsoft Cloud Workshops")

<div class="MCWHeader1">
DataOps
</div>

<div class="MCWHeader2">
Hands-on lab step-by-step
</div>

<div class="MCWHeader3">
May 2021
</div>

Information in this document, including URL and other Internet Web site references, is subject to change without notice. Unless otherwise noted, the example companies, organizations, products, domain names, e-mail addresses, logos, people, places, and events depicted herein are fictitious, and no association with any real company, organization, product, domain name, e-mail address, logo, person, place or event is intended or should be inferred. Complying with all applicable copyright laws is the responsibility of the user. Without limiting the rights under copyright, no part of this document may be reproduced, stored in or introduced into a retrieval system, or transmitted in any form or by any means (electronic, mechanical, photocopying, recording, or otherwise), or for any purpose, without the express written permission of Microsoft Corporation.

Microsoft may have patents, patent applications, trademarks, copyrights, or other intellectual property rights covering subject matter in this document. Except as expressly provided in any written license agreement from Microsoft, the furnishing of this document does not give you any license to these patents, trademarks, copyrights, or other intellectual property.

The names of manufacturers, products, or URLs are provided for informational purposes only and Microsoft makes no representations and warranties, either expressed, implied, or statutory, regarding these manufacturers or the use of the products with any Microsoft technologies. The inclusion of a manufacturer or product does not imply endorsement of Microsoft of the manufacturer or product. Links may be provided to third party sites. Such sites are not under the control of Microsoft and Microsoft is not responsible for the contents of any linked site or any link contained in a linked site, or any changes or updates to such sites. Microsoft is not responsible for webcasting or any other form of transmission received from any linked site. Microsoft is providing these links to you only as a convenience, and the inclusion of any link does not imply endorsement of Microsoft of the site or the products contained therein.

© 2021 Microsoft Corporation. All rights reserved.

Microsoft and the trademarks listed at <https://www.microsoft.com/en-us/legal/intellectualproperty/Trademarks/Usage/General.aspx> are trademarks of the Microsoft group of companies. All other trademarks are property of their respective owners.

**Contents** 

<!-- TOC -->
- [DataOps hands-on lab step-by-step](#leveraging-azure-digital-twins-in-a-supply-chain-hands-on-lab-step-by-step)
  - [Abstract and learning objectives](#abstract-and-learning-objectives)
  - [Overview](#overview)
  - [Solution architecture](#solution-architecture)
  - [Requirements](#requirements)
  - [Before the hands-on lab](#before-the-hands-on-lab) (20 min) (Owner: Renan)
  - [Exercise 1: Exploring Azure Data Services](#Exercise-1-Exploring-Azure-Data-Services) (30 min) (Owner: Maritza)
    - [Task 1: Azure Data Lake Storage](#Task-1-Azure-Data-Lake-Storage)
    - [Task 2: Azure Data Factory](#Task-2-Azure-Data-Factory)
    - [Task 3: Azure Databricks](#Task-3-Azure-Databricks)
  - [Exercise 2: Infrastructure As Code](#Exercise-2-Infrastructure-As-Code) (30 min) (Owner: Jaque)
    - [Task 1: Understanding the IaC folder]()
    - [Task 2: Creating a new sandbox environment with Powershell]()
    - [Task 3: Checklist of IaC best practices]()
  - [Exercise 3: Git Workflow and CI/CD](#Exercise-3-Git-Workflow-and-CI/CD) (45 min) (Owner: Ana/Adrian)
    - [Task 1: Understanding all repositories]()
    - [Task 2: Understanding naming conventions for branches and commits]()
    - [Task 3: Release lifecycle strategy]()
    - [Task 4: Commiting and releasing a feature to ADF]()
    - [Task 5: CI Pipelines]()
    - [Task 6: CD Pipelines]()
    - [Task 7: Checklist of branching strategy (?) racionality]()
  - [Exercise 4: Semantic Versioning of Data Engineering Libraries](#Exercise-4-Semantic-Versioning-of-Data-Engineering-Libraries) (25 min) (Owner: Leandro)
    - [Task 1: Building custom libraries for data engineering]()
    - [Task 2: The Git workflow for data]()
    - [Task 3: Creating a new PR for the custom library]()
    - [Task 4: Custom libraries checklist]()
  - [Exercise 5: Testing](#Exercise-5-Testing) (25 min)
    - [Task 1: Understanding test types](#Task-1-Understanding-test-types)
    - [Task 2: Understanding BDD tests](#Task-1-Understanding-BDD-tests)
    - [Task 3: Developing a new test]()
  - [Exercise 6: ML PLatform (optional)]() (30 min) (TBD)
  - [After the hands-on lab](#after-the-hands-on-lab)
    - [Task 1: Delete resource group](#task-1-delete-resource-group)
<!-- /TOC -->

# Leveraging Azure Digital Twins in a supply chain hands-on lab step-by-step

## Abstract and learning objectives

...

At the end of this hands-on lab, you will be better able to implement an end-to-end Data Engineering pipeline leveraging DataOps & Software Engineering best practices.

## Overview

...

## Solution architecture

Below is a diagram of the solution architecture you will deploy in this lab, leveraging several DataOps best practices.

!['Solution Architecture'](media/high-level-overview-dataops.png)

Explain each one of the repos that will be user for this workshop:
- IaC
- Data Platform
- ML Platform
- Docs

## Requirements

1. Microsoft Azure subscription must be pay-as-you-go or MSDN.
    - Trial subscriptions will not work.

2. Follow all the steps provided in [Before the Hands-on Lab](Before%20the%20HOL%20-%20DataOps.md)


## Before the hands-on lab

Refer to the Before the hands-on lab setup guide manual before continuing to the lab exercises.


## Exercise 1: Exploring Azure Data Services

Duration: 20 minutes

In this exercise, you will explore the main resources that have been deployed in your Azure Subscription.

The resource groups rerg-dataops-data-dev and rg-dataops-compute-dev contain data and compute services respectively.  

!['Resource groups'](media/resource-groups.png)

The rg-dataops-data resource group contains a [Data Lake Storage] (https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-introduction) and a [Blob Storage] (https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-overview) 

!['Resource group: Data'](media/rg-dataops-data-dev.png)

The resource group rg-dataops-compute contains an instance of [Azure Data Factory] (https://docs.microsoft.com/en-us/azure/data-factory/) and [Azure Databricks] (https://docs.microsoft.com/en-us/azure/databricks/)

!['Resource group: Compute'](media/rg-dataops-compute-dev.png)

### Technology Overview 

Azure Databricks and Azure Data Lake enable modern data architectures simplifying and accelerating the data processing at any scale.

Azure Data Factory loads raw data into Azure Blob Storage and Azure Databricks processes the data and organize it into layers: landing, refined, trusted

Azure Delta Lake forms the curated layer of the data lake. It stores the refined data in an open-source format

### Task 1: Explore Azure Blob Storage

In this task, you will explore the Azure Blob Storage instance. 

1. Open the Azure Portal and navigate to the rg-dataops-data resource group and select the stgdataopseastus2dev Azure Blob Storage. 

2. On the overview blade, select Containers

!['Blob Storage Overview'](media/stgdataopseastus2dev.png)

3. Select and open the flights-data container.

!['Containers'](media/stgdataopseastus2dev-containers.png)

4. Review the CSV files. Select the CSV file and download it. 

!['Files'](media/stgdataopseastus2dev-airport-metadata.png)

### Task 2: Explore Azure Data Lake Storage

In this task, you will explore the layers defined to organize the data into the Data Lake. The landing layer is for raw ingestion, and trusted layer is for the filtered and cleaned data.  

1. Open the Azure Portal and navigate to the rg-dataops-data resoruce group and select the Azure Data Lake instance lakedataopseastus2dev. 

2. On the Overview blade, select Containers

!['Data Lake overview'](media/lakedataopseastus2dev-overview.png)

3. Select and open the landing layer container.

!['Containers'](media/lakedataopseastus2dev-layers.png)

4. Select and open the directories airport-metada, flight-delays, flight-weather. They will contain CSV files with the infomation about airports, flights and weather. 

!['Landing layer'](media/lakedataopseastus2dev-layer-landing.png)

### Task 3: Azure Databricks
 
In this task, you will explore the Azure Databricks instance dbw-dataops-eastus2-dev. This resource contains notebooks with code to prepare and clean the data. 

1. Navigate to the Azure Databricks instance dbw-dataops-eastus2-dev and Launch the Workspace. 

!['Databricks overview'](media/dbw-dataops-eastus2-dev-overview.png)

2. Navigate to the Workspace hub (2). Open the folders shared with you (if someone share wiht you the databricks instance) or seek your user in Users (3). Open the DataOps Folder (4) and select the notebook named 01 ADLS Mount (5).  

!['Databricks workspace'](media/dbw-dataops-eastus2-dev-ws.png)

3. To run the notebook you need attach a cluster from the list (1) or create a new one if you don't have clusters deployed. 

!['Attach a cluster'](media/notebook-01-adls-mount.png)

3.1 Provide a name for the new cluster, establish the cluster setting and select Create Cluster.

!['Creating a cluster'](media/dbw-dataops-new-cluster.png)

3.2 Navigate back to the notebook named 01 ADLS Mount and attach the cluster

!['Creating a cluster'](media/dbw-dataops-attaching-cluster.png) 

4. Select Run Cell or Crt + Enter to run the cell and amount the Azure Data Lake. 
This code is to mount the Azure Data Lake Storage Gen2 account to Databricks File System. For the authentication, it uses Key Vault and OAuth 2.0.

!['Run'](media/notebook-01-adls-runcell.png)  

5. Navigate back to the notebook named 02 One Notebook to Rule Them All.

5.1 Run the cells to import the libraries that you will use to process and transform the data.

!['Run'](media/02-One-Notebook-to-Rule-Them-All-1.png)  

5.2 Read the file FlightDelaysWithAirportCodes.csv from the landing layer (1), transform the data (2), and create the a local table called flight_delays_with_airport_codes from the flight_delays_df Dataframe (3).  

!['Run'](media/02-One-Notebook-to-Rule-Them-All-2.png) 

5.3 Select clean columns to generate clean data (1) and save the clean data as a global table called flight_delays_clean (2). 

!['Run'](media/02-One-Notebook-to-Rule-Them-All-3.png) 

5.4 To see the created table: Click Data in the sidebar (1). In the databases folder, click on the default database (2). Open Tables Folder and Click the table name.  

!['Run'](media/globaltable-flight_delays_view.png) 

5.5 Navigate back to the notebook. Run cells 9, 10 and 11 to prepare the weather data. Cell 9 reads raw data from landing layer and create a local table called flight_weather_with_airport_code. Cell 10 transforms data and Cell 11 creates a global table called flight_weather_clean.

!['Run'](media/02-One-Notebook-to-Rule-Them-All-4.png) 

5.5 Run the rest of cells. Cell 14 copies clean data of flight dealys and weather into the trusted layer of the data lake (1). Cell 16 saves data of airports with the delayes into the logs folder as CSV file (trusted layer) (2). Finally,the path of the CSV file will be the notebook output (3).

!['Run'](media/02-One-Notebook-to-Rule-Them-All-5.png) 

### Task 4: Azure Data Factory

In this task, you will explore the adf-dataops-eastus2-dev Azure Data Factory instance. 

1. Navigate to the adf-dataops-eastus2-dev Azure Data Factory instance and launch the workspace (Author & Monitor). 

!['Azure Data Factory Overview'](media/adf-dataops-eastus2-dev-overview.png)

2. Navigate to the Author hub.

!['Azure Data Factory Hub'](media/adf-dataops-eastus2-dev-workspace1.png)

3. You will find the pipeline ProcessFlightDelaysData and 6 datasets. The pipeline contains the activities to copy data from the XXXXXXXSource datasets into the XXXXXXSink datasets.

!['Author Hub'](media/adf-dataops-eastus2-dev-author.png)

4. Open the pipeline ProcessFlightDelaysData and review the settings of the activities:
- Copy Airport Codes Data
- Copy Flights Delays  Data
- Copy Flights Weather Data
- Mount ADLS
- Transform Flights Data

!['Pipeline'](media/adf-dataops-eastus2-dev-process-data.png)

4.1. Select the Copy Airport Codes Data (1). Select the Source Tab (2) and Click on Open to see the settings of the AirportCodesSource dataset (3).

!['Copy Airport Codes Data'](media/copy-airport-codes.png)

4.2  Select Edit to review the Azure blob Storage linked service (1). View the file path that you want to copy (2). Select Browse to navigate into the stgdataopseastus2dev Azure Blob Storage instance (3) and Select the file path.  

!['Airport Codes Source dataset'](media/airport-codes-source-csv.png)

4.3 Navigate back to the Copy Airport Codes Data Activity in the pipeline ProcessFlightDelaysData. Select the Sink tab (1) and Click on Open to see the setting of the AirportCodesSink dataset (2).

!['Sink'](media/copy-airport-codes-sink.png)

4.4. Select Edit to review the Azure Data Lake linked service (1). View the layer  where you will copy the data (2). Select Browse to navigate into the lakedataopseastus2dev Azure Data Lake instance (3) and select the  layer (4).  

!['Airport dataset'](media/airport-codes-sync.png)

5. Repeat the steps 4.1 - 4.4 for the Copy Flights Delays Data and Copy Flights Weather Data activities.

6. Navigate back to the pipeline and select the notebook activity Mount ADLS. Select the Azure Databricks tab (1) and click on Edit to view the settings of the linked service of the Databricks instance.

!['Notebook activity'](media/mount-adls-1.png )

7. Select the settings tab of the notebook activity to configure the notebook to run in the databricks instance (1). In the Notebook path, indicate the path of the notebook to run (2). Select Browse if you want to explore the available notebooks (3) and explore the available folders in the Databricks instance (4). Select Open to open the Databricks workspace. 

8. Repeat the steps 6 and 7 to explore the Notebook Activity Transform Flight Data. 

!['Notebook activity'](media/mount-adls-2.png)

9. OPTIONAL - Navigate back to the pipeline and run it. 

!['Execute pipeline'](media/pipeline-trigger.png)

9.1 Navigate to the Data Lake. Follow the file path that you indicated in the step 4.4. You will find the CSV file just copied. 

!['Exploring Data Lake'](media/lakedataopseastus2dev-airport-metadata.png)

## Exercise 2: Infrastructure As Code

Duration: 30 minutes

In this exercise, you will explore and understand the structure and contents of the IaC folder, which contains all the scripts and templates necessary to correctly perform this and other exercises in this lab, using a best practices model.

### Technology Overview - Infrastructure As Code Practice

Infrastructure as Code (IaC) is the management of infrastructure (networks, virtual machines, load balancers, and connection topology) in a descriptive model, using the same versioning as DevOps team uses for source code. Like the principle that the same source code generates the same binary, an IaC model generates the same environment every time it is applied. IaC is a key DevOps practice and is used in conjunction with continuous delivery. (https://docs.microsoft.com/en-us/devops/deliver/what-is-infrastructure-as-code)

### Task 1: Understanding the IaC folder

In this task you will explore and understand the folder structure and scripts, templates contained in it for execution in IaC.

To proceed with the execution of the other exercises below, you must understand the structure of the "infrastructure-as-code" folder, as well as its content of templates and scripts.

!['infrastructure as code'](media/infrastructure-as-code-folder.png)

```
|infrastructure-as-code|
	|databricks|
		|dev|
			interactive.json
		|prod|
			interactive.json
		|qa|
			interactive.json
		|sandbox|
			core.json
	|infrastructure|
		|linkedTemplates|
			|compute|
				template.json
			|data|
				template.json
			|ml|
				template.json
			|roleAssigments|
				compute.json
				data.json
		|parameters|
			parameters.dev.json
			parameters.dev.template.json
			parameters.prod.json
			parameters.prod.template.json
			parameters.qa.json
			parameters.qa.template.json
		azuredeploy.json
	|scripts|
		AcceptanceTest.ps1
		DatabricksClusters.ps1
		DatabricksSecrets.ps1
		Deploy.ps1
		Lint.ps1
		Plan.ps1
		PublishOutputs.ps1
		Sandbox.ps1
		Setup.ps1
		UploadSampleData.ps1
	|tests|
		|Compute|
			Databricks.Tests.ps1
			DataFactory.Tests.ps1
			KeyVault.Tests.ps1
			ResourceGroup.Tests.ps1
			RoleAssigments.Tests.ps1
		|Data|
			DataLake.Tests.ps1
			ResourceGroup.Tests.ps1
	GitVersion.yml
```
### Technology Overview - Azure Resource Manager Templates

To implement infrastructure as code for your Azure solutions, use Azure Resource Manager templates (ARM templates). The template is a JavaScript Object Notation (JSON) file that defines the infrastructure and configuration for your project. The template uses declarative syntax, which lets you state what you intend to deploy without having to write the sequence of programming commands to create it. In the template, you specify the resources to deploy and the properties for those resources. (https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/overview)

# Folder [infrastructure]

```
|infrastructure|
		|linkedTemplates|
			|compute|
				template.json
			|data|
				template.json
			|ml|
				template.json
			|roleAssigments|
				compute.json
				data.json
		|parameters|
			parameters.dev.json
			parameters.dev.template.json
			parameters.prod.json
			parameters.prod.template.json
			parameters.qa.json
			parameters.qa.template.json
		azuredeploy.json
```
# File: azuredeploy.json
Main template, with declared parameters, variables and resources. Here we use linkedTemplates.
*NOTE*: We have the option of using separate parameter files as a good practice when using IaC templates, without the need to change directly in the main template.

```
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environment": {
      "type": "string",
      "metadata": {
        "description": "Environment where resources will be deployed"
      }
    },
    "solutionName": {
      "type": "string",
      "metadata": {
        "description": "Solution name"
      }
    },    
    "location": {
      "type": "string",
      "metadata": {
        "description": "Region where the resource is provisioned"
      }
    }, 
    "resourceGroupData": {
      "type": "string",
      "metadata": {
        "description": "Resource group where 'Data' resources will be provisioned"
      }
    },
    "resourceGroupCompute": {
      "type": "string",
      "metadata": {
        "description": "Resource group where 'Compute' resources will be provisioned"
      }
    },
    "resourceGroupMachineLearning": {
      "type": "string",
      "metadata": {
        "description": "Resource group where 'Machine Learning' resources will be provisioned"
      }
    },
    "resourceGroupManagedDatabricks": {
      "type": "string",
      "metadata": {
        "description": "SKU type name for the dataLake"
      }
    },
    "dataLakeSkuName": {
      "type": "string",
      "metadata": {
        "description": "SKU type name for the datalake"
      }
    },
    "dataFactoryAccountName": {
      "type": "string",
      "defaultValue": "",
      "metadata": {
        "description": "Azure DevOps account name"
      }
    },
    "dataFactoryProjectName": {
      "type": "string",
      "defaultValue": "",
      "metadata": {
        "description": "Project name in Azure DevOps account"
      }
    },
    "dataFactoryRepositoryName": {
      "type": "string",
      "defaultValue": "",
      "metadata": {
        "description": "Azure DevOps project repository name for DataFactory"
      }
    },
    "dataFactoryCollaborationBranch": {
      "type": "string",
      "defaultValue": "",
      "metadata": {
        "description": "Collaboration branch: develop"
      }
    },
    "dataFactoryRootFolder": {
      "type": "string",
      "defaultValue": "",
      "metadata": {
        "description": "Root folder of the datafactory: /adf"
      }
    },
    "keyVaultSecretsAdminObjectId": {
      "type": "string",
      "metadata": {
        "description": "ObjectId of the person creating the secrets"
      }
    }
  },
  "functions": [
    {
      "namespace": "naming",
      "members": {
        "default": {
          "parameters": [
            {
              "name": "resourcePurpose",
              "type": "string"
            },
            {
              "name": "uniqueStr",
              "type": "string"
            },
            {
              "name": "environment",
              "type": "string"
            },
            {
              "name": "solutionName",
              "type": "string"
            }            
          ],
          "output": {
            "type": "string",
            "value": "[concat(parameters('resourcePurpose'), '-', parameters('solutionName'), '-', parameters('uniqueStr'), '-',  parameters('environment'))]"
          }
        },
        "clean": {
          "parameters": [
            {
              "name": "resourcePurpose",
              "type": "string"
            },
            {
              "name": "uniqueStr",
              "type": "string"
            },
            {
              "name": "environment",
              "type": "string"
            },
            {
              "name": "solutionName",
              "type": "string"
            }            
          ],
          "output": {
            "type": "string",
            "value": "[concat(parameters('resourcePurpose'), parameters('solutionName'), parameters('uniqueStr'), parameters('environment'))]"
          }
        }
      }
    }
  ],
  "variables": {
    "envMapping": {
      "eastus": "eastus",
      "brazilsouth": "brzsouth"
    },
    "uniqueStr": "[substring(uniqueString(subscription().subscriptionId), 0, 6)]",
    "dataDeploymentName": "[concat('data-', deployment().name)]",
    "computeDeploymentName": "[concat('compute-', deployment().name)]",
    "mlDeploymentName": "[concat('ml-', deployment().name)]",
    "dataRoleAssigmentsDeploymentName": "[concat('data-roleAssigments-', deployment().name)]",
    "computeRoleAssigmentsDeploymentName": "[concat('compute-roleAssigments-', deployment().name)]",
    "dataSourceStorageAccountName": "[naming.clean('stg',variables('uniqueStr'), parameters('environment'), parameters('solutionName'))]",
    "dataLakeName": "[naming.clean('lake',variables('uniqueStr'), parameters('environment'), parameters('solutionName'))]",
    "databricksName": "[naming.default('dbw',variables('uniqueStr'), parameters('environment'), parameters('solutionName'))]",
    "dataFactoryName": "[naming.default('adf',variables('uniqueStr'), parameters('environment'), parameters('solutionName'))]",
    "keyVaultName": "[naming.default('kv',variables('uniqueStr'), parameters('environment'), parameters('solutionName'))]",
    "amlWorkspaceName": "[naming.default('mlw',variables('uniqueStr'), parameters('environment'), parameters('solutionName'))]",
    "amlKeyVaultName": "[naming.default('kvm',variables('uniqueStr'), parameters('environment'), parameters('solutionName'))]",
    "amlStorageAccountName": "[naming.clean('stml',variables('uniqueStr'), parameters('environment'), parameters('solutionName'))]",
    "amlApplicationInsightsName": "[naming.default('appi-ml',variables('uniqueStr'), parameters('environment'), parameters('solutionName'))]",
    "amlContainerRegistryName": "[naming.clean('crml',variables('uniqueStr'), parameters('environment'), parameters('solutionName'))]"
  },
  "resources": [
    {
      "type": "Microsoft.Resources/deployments",
      "apiVersion": "2020-06-01",
      "name": "[variables('dataDeploymentName')]",
      "resourceGroup": "[parameters('resourceGroupData')]",
      "properties": {
        "mode": "Incremental",
        "templateLink": {
          "relativePath": "linkedTemplates/data/template.json"
        },
        "parameters": {
          "location": {
            "value": "[parameters('location')]"
          },
          "dataSourceStorageAccountName": {
            "value": "[variables('dataSourceStorageAccountName')]"
          },          
          "dataLakeName": {
            "value": "[variables('dataLakeName')]"
          },
          "dataLakeSkuName": {
            "value": "[parameters('dataLakeSkuName')]"
          }
        }
      }         
    },
    {
      "type": "Microsoft.Resources/deployments",
      "apiVersion": "2020-06-01",
      "name": "[variables('computeDeploymentName')]",
      "resourceGroup": "[parameters('resourceGroupCompute')]",
      "properties": {
        "mode": "Incremental",
        "templateLink": {
          "relativePath": "linkedTemplates/compute/template.json"
        },
        "parameters": {
          "environment": {
            "value": "[parameters('environment')]"
          },
          "location": {
            "value": "[parameters('location')]"
          },
          "dataFactoryName": {
            "value": "[variables('dataFactoryName')]"
          },
          "dataFactoryAccountName": {
            "value": "[parameters('dataFactoryAccountName')]"
          },
          "dataFactoryProjectName": {
            "value": "[parameters('dataFactoryProjectName')]"
          },
          "dataFactoryRepositoryName": {
            "value": "[parameters('dataFactoryRepositoryName')]"
          },
          "dataFactoryCollaborationBranch": {
            "value": "[parameters('dataFactoryCollaborationBranch')]"
          },
          "dataFactoryRootFolder": {
            "value": "[parameters('dataFactoryRootFolder')]"
          },
          "resourceGroupManagedDatabricks": {
            "value": "[parameters('resourceGroupManagedDatabricks')]"
          },
          "databricksName": {
            "value": "[variables('databricksName')]"
          },
          "keyVaultName": {
            "value": "[variables('keyVaultName')]"
          },
          "keyVaultSecrets": {
            "value": {
              "secrets": [           
                {
                  "secretName": "dataLakeName",
                  "secretValue": "[variables('dataLakeName')]"
                },
                {
                  "secretName": "StorageAccountConnectionString",
                  "secretValue": "[concat('DefaultEndpointsProtocol=https;AccountName=', variables('dataSourceStorageAccountName'), ';AccountKey=', listKeys(concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/', parameters('resourceGroupData'), '/providers/Microsoft.Storage/storageAccounts/', variables('dataSourceStorageAccountName')), '2019-04-01').keys[0].value,';EndpointSuffix=core.windows.net')]"
                }  
              ]
            }
          },
          "keyVaultSecretsAdminObjectId": {
            "value": "[parameters('keyVaultSecretsAdminObjectId')]"
          }        
        }
      },
      "dependsOn": [
        "[variables('dataDeploymentName')]"
      ]
    },
    {
      "type": "Microsoft.Resources/deployments",
      "apiVersion": "2020-06-01",
      "name": "[variables('dataRoleAssigmentsDeploymentName')]",
      "resourceGroup": "[parameters('resourceGroupData')]",
      "properties": {
        "mode": "Incremental",
        "templateLink": {
          "relativePath": "linkedTemplates/roleAssigments/data.json"
        },
        "parameters": {
          "dataLakeName": {
            "value": "[variables('dataLakeName')]"
          },
          "dataFactoryPrincipalId": {
            "value": "[reference(variables('computeDeploymentName')).outputs.dataFactoryPrincipalId.value]"
          }
        }
      },
      "dependsOn": [
        "[variables('computeDeploymentName')]"
      ]
    },
    {
      "type": "Microsoft.Resources/deployments",
      "apiVersion": "2020-06-01",
      "name": "[variables('computeRoleAssigmentsDeploymentName')]",
      "resourceGroup": "[parameters('resourceGroupCompute')]",
      "properties": {
        "mode": "Incremental",
        "templateLink": {
          "relativePath": "linkedTemplates/roleAssigments/compute.json"
        },
        "parameters": {
          "databricksName": {
            "value": "[variables('databricksName')]"
          },
          "dataFactoryPrincipalId": {
            "value": "[reference(variables('computeDeploymentName')).outputs.dataFactoryPrincipalId.value]"
          }
        }
      },
      "dependsOn": [
        "[variables('computeDeploymentName')]"
      ]
    },
    {
      "type": "Microsoft.Resources/deployments",
      "apiVersion": "2020-06-01",
      "name": "[variables('mlDeploymentName')]",
      "resourceGroup": "[parameters('resourceGroupMachineLearning')]",
      "properties": {
        "mode": "Incremental",
        "templateLink": {
          "relativePath": "linkedTemplates/ml/template.json"
        },
        "parameters": {
          "location": {
            "value": "[parameters('location')]"
          },
          "amlWorkspaceName": {
            "value": "[variables('amlWorkspaceName')]"
          },
          "amlKeyVaultName": {
            "value": "[variables('amlKeyVaultName')]"
          },
          "amlStorageAccountName": {
            "value": "[variables('amlStorageAccountName')]"
          },
          "amlApplicationInsightsName": {
            "value": "[variables('amlApplicationInsightsName')]"
          },
          "amlContainerRegistryName": {
            "value": "[variables('amlContainerRegistryName')]"
          }
        }
      }         
    }
  ],
  "outputs": {
    "location": {
      "type": "string",
      "value": "[parameters('location')]"
    },
    "resourceGroupData": {
      "type": "string",
      "value": "[parameters('resourceGroupData')]"
    },
    "resourceGroupCompute": {
      "type": "string",
      "value": "[parameters('resourceGroupCompute')]"
    },
    "resourceGroupML": {
      "type": "string",
      "value": "[parameters('resourceGroupMachineLearning')]"
    },
    "dataSourceStorageAccountName": {
      "type": "string",
      "value": "[variables('dataSourceStorageAccountName')]"
    },    
    "dataLakeName": {
      "type": "string",
      "value": "[variables('dataLakeName')]"
    },
    "dataLakeSkuName": {
      "type": "string",
      "value": "[parameters('dataLakeSkuName')]"
    },
    "dataFactoryName": {
      "type": "string",
      "value": "[variables('dataFactoryName')]"
    },
    "databricksName": {
      "type": "string",
      "value": "[variables('databricksName')]"
    },
    "databricksWorkspaceUrl": {
      "type": "string",
      "value": "[reference(variables('computeDeploymentName')).outputs.databricksWorkspaceUrl.value]"
    },
    "keyVaultName": {
      "type": "string",
      "value": "[variables('keyVaultName')]"
    },
    "amlWorkspaceName": {
      "type": "string",
      "value": "[variables('amlWorkspaceName')]"
    },
    "amlKeyVaultName": {
      "type": "string",
      "value": "[variables('amlKeyVaultName')]"
    },
    "amlStorageAccountName": {
      "type": "string",
      "value": "[variables('amlStorageAccountName')]"
    },
    "amlApplicationInsightsName": {
      "type": "string",
      "value": "[variables('amlApplicationInsightsName')]"
    },
    "amlContainerRegistryName": {
      "type": "string",
      "value": "[variables('amlContainerRegistryName')]"
    }
  }
}
```

# Folder: linkedTemplates
```
|linkedTemplates|
			|compute|
				template.json
			|data|
				template.json
			|ml|
				template.json
			|roleAssigments|
				compute.json
				data.json
```

In linkedTemplates we have templates with "parts" of declared resources that are not declared in the main Template, in order to reuse and can link with other templates.
*NOTE*: linkedTemplates is a widely used practice, for better organization and handling of templates of different types of resources and being able to link them to any template.

!['compute-linkedTemplate'](media/compute-template-json.png)

# Folder: parameters
```
|parameters|
			parameters.dev.json
			parameters.dev.template.json
			parameters.prod.json
			parameters.prod.template.json
			parameters.qa.json
			parameters.qa.template.json
```

Parameters folder and directory with templates files with parameters and values to be used by linkedTemplates and main template, without the need to change directly in the main template.
*NOTE*: Using templates parameters is optional and can be used directly in the main template. However, following a model of good practice, the use separately is indicated.

!['parameters-dev-json'](media/parameters-dev-json.png)

### Task 2: Creating a new sandbox environment with Powershell

In this task you will learn how to create your first sandbox environment, with Azure Powershell scripts.

### Task 3: Checklist of IaC best practices

In this task you will understand the best practices in creating, executing and managing scripts and templates in IaC.

1. Codify everything

2. Document as little as possible

3. Maintain version control
Version your templates in a code repository, such as Azure Repos, GitHub, etc.
By versioning your templates you can control and reuse them with your development team or infrastructure at any time, in addition to ensuring the version history.

4. Continuously test, integrate, and deploy

5. Make your infrastructure code modular

6. Make your infrastructure immutable (when possible)


## Exercise 3: Git Workflow and CI/CD

Duration: 45 minutes

## Exercise 4: Semantic Versioning of Data Engineering Libraries

Duration: 25 minutes

In the DataOps culture, the data engineer team moves at lightning speed using highly optimized methodology, tools, and processes. One of the most important productivity methodologies is the ability to reuse codes. When we talk about reusing code, we mean about the approach to reuse data engineering codes that are responsible to do default data transformations for your data sets. 

When we talk about data engineering approach in a data analytics project, automatically we think about [Notebooks](https://en.wikipedia.org/wiki/Notebook_interface). Use notebooks is good to analyze, make experimentations and apply techniques of curate data in the pipelines. However oftentimes in a project it can become a manually task, as a copy and paste codes across notebooks.  To address necessities like this, optimize the processes and save the time, we can develop custom libraries to abstract these data engineering practices, and use them around the notebooks.

In this exercise you will learn how to implement a semantic versioning using a custom library in Python.

### Exploring the Databricks Notebook

Open the **02 One Notebook to Rule them all** notebook (located in the Workspace Databricks, under Notebook’s area) and run it step by step to complete this first step. Some of the most important tasks you will perform are:
	•  Install and import a custom python library
	•  Prepare and apply data quality in the flight delays and whether data sets.
	• Transform and combining dates columns between flights delay and whether forecast data set using the custom python library

**IMPORTANT NOTE**
_Please note that each of these tasks will be addressed through several cells in the notebook. You don’t need to change them only execute and analyze the transformation operations._

### Exploring the Python custom libraries. 

In previous exercise we explored the databricks notebook, and we used a custom library responsible for the main transformations in the data sets of flights delays and whether. Now, let’s to explore and understand some approaches to creating custom libraries in data analytics projects.

**IMPORTANT NOTE**
_Please note that we will use existing custom libraries in the repository, won’t be necessary to develop a new library to this exercise._

**For the remainder of this guide, the following pre-requirements will be necessary to execute and validate the library locally:**

*	Python 3.x
*	Docker + Docker Compose
*	Java SDK
*	Visual Studio Code

1. Open the HOL directory in your prompt and execute **“code .”**  to open the Visual Studio Code:

_[Image]_


2. From the left explorer view, open the **“data-platform/src”** directory structure. 


_[Image]_

3. Inside the structure you will have all items necessary to develop and validate a custom library. To proceed with the validation, we will investigate the existing library used in the databricks notebook. For that, open the **“spark”** directory and click on the file **“data_transformation.py”**

_[Image]_

4. If you look in the code library, will notice that there is a lot of functions that is used in the databricks notebooks to address data cleanings and transformations. Let’s look at one of them. Press *CTRL+F* type **“make_datetime_column”** and click OK. You will see that in this part of the code, we are using is a pretty common practice for some datasets:

_[Image]_


5.	From the left menu explorer, you will see others library, but before to execute and test them locally you will need to setup the configuration of the environment. For that, follow the steps **6** and **7**.


6. Create a virtual environment and install the required packages:

    ```sh
      python3 -m venv dataopslib_env
      source dataopslib_env/bin/activate

      pip3 install -r requirements.txt
    ```

7. Open the `spark` folder on your terminal and run the Docker compose to start an Apache Spark instance locally:

    ```sh
       docker-compose up
    ```


8. Now we already have the environment prepared and to start the execution of some existing libraries. Choose more one sample to test, open the samples folder, click on the file **“sample_read_csv.py”** and press F5.


_[Image]_

9. Now let's imagine that we need to add a new function to address new functionalities in our pipeline. We could add this new feature in the library and promote that to our pipeline. Here the intention is just to show how is the process to promote to QA, so let’s to add a simple code:

    ```
    def `make_datetime_column_new`(df: DataFrame, columnName: str, year: str, month: str, day: str,
                         hour: Union[str, None] = None, minute: Union[str, None] = None,
                         second: Union[str, None] = None, time: [str, None] = None,
                         timeFormat: str = 'HH:mm:ss') -> DataFrame:
     ```


10. Until we were able to abstract certain functions inside a library and reuse them in the notebooks. But now, let’s imagine that we need to create a new feature for this library, or maybe fix a bug, how to versioning this code? Let's to learn that in the next exercise.

_[Image]_

## Exercise 5: Testing  {#Exercise-5-Testing}

Duration: 25 minutes

### Task 1: Understanding test types

  Testing data pipelines has unique challenges that makes it different from testing traditional software. You have data pipelines that pulls data from many source systems, ensure data quality (i.e. ensure that bad data is identified, then blocked, scrubbed, fixed, or just logged), combines this data, transforms and scrubs it. Then the data is stored in some processed state for consumption by downstream systems, analytics platforms, or data scientists. These pipelines often process data from *hundreds* or even *thousands* of sources. You run your pipelines and get *several* million new rows in your consumption layer.

  Then you create full end-to-end functional tests for the pipelines. The pipelines are getting more complex over time, and the tests are becoming harder to understand and maintain. Then you start thinking:

  * How to make the tests as readable as possible?
  * How to improve tests maintainability?
  * *How to effectively communicate the **current behavior** of the data pipelines with the team or across teams?*

  Leveraging the concepts of Behavior-Driven Development (BDD) could be the answer for these questions. BDD uses **human-readable** descriptions of software user requirements as the basis for software tests, where we define a shared vocabulary between stakeholders, domain experts, and engineers. This process involves the definition of entities, events, and outputs that the users care about, and giving them names that everybody can agree on.

  **Testing Strategy**

  *Language and Frameworks*

  Data engineers and data scientists are turning decisively to Python - according to the [O'Reilly annual usage analysis](https://www.oreilly.com/radar/oreilly-2020-platform-analysis/) - due to its applicability and its tools for data analysis and ML/AI.

  For this reason, the tests in this repository are written in Python using the most used open-source BDD framework called [behave](https://github.com/behave/behave). The framework leverages the use of [Gherkin](https://cucumber.io/docs/gherkin/reference/) to write tests, a well-known language used in BDD designed to be human readable.

  *Structure of tests*

  Essentially the test files are structured in two levels:

  * **Features**: Files where we specify the expected behavior of the data pipelines based on the existing requirements that can be understood by all people involved (e.g. data engineers, data scientists, business analysts). The specifications are written in Gherkin format.
  * **Steps**: Files where we implement the scenarios defined on feature files. These files are written in Python.

  >On the next Task of this lab, you will explore an example that it is already implemented as part of the full solution deployment. (See Exercise 3)

### Task 2: Understanding BDD tests

> **Prerequiste for this task:** Succesful completion of Excersise 3

Objective of this Task: Review how a Pipeline test was configured and explore the results of the BDD execution.

First review how the DevOps pipeline was defined:

  1. Go to the repositoy that was created as part the Exercise 3, Task # and open the templates folder, were you will see 3 yml files.

!['Templastes Folder'](media/templates-folder.png)

  2. Open the test.yml file by clicking on it

!['Test yml'](media/select-test-yml.png)

  3. Indentify the script activity that runs the behave modulo and identify the different paramentes that are set before it is called

!['Behave activity'](media/behave-script.png)

Now lets review the DevOps pipeline execution results:
  
  1. Go to DevOps Pipelines from the project defined on Execise 3 and select the Pipeline with the name "*\<your lab prefix>*-adf-cd" by clciking on it.

!['Last Pipeline Run'](media/last-pipeline-run.png) 

  2. You will see a list of resent runs of the selected pipeline, click on the lates run

  3. At the stages secction select the "Run behavior tests" stage

 !['Pipeline Stages'](media/pipeline-stages-run.png) 
  
  4. Review the Azure DevOps execution results for "Run behavior tests"\\"TEST: Run behave features"

  !['Pipeline Results'](media/pipeline-run-results.png)

  <p>Here you see the results of running the BDD test using <b>behave</b></p>

> On the next optional task you could explore how to build your own Data Pipeline BDD test
### Task 3: Developing a new test (Optional)

> **Prerequiste for this task:** Have Visual Studio Code (VS Code) installed and configured to run Python 3.7 projects - this setup is out of scope of this lab

Objective of this Task: Explore how Behavior Driven Development is implemented with "behave" framework

  1. Go to your Development environment were you have installed VS Code and clone the data-platform repo that is part of the HOL

  2. Go to src directory and read the readme.md

## After the hands-on lab

Duration: 5 minutes

### Task 1: Delete resource group

1. In the [Azure Portal](https://portal.azure.com), delete the resource group you created for this lab.

You should follow all steps provided *after* attending the Hands-on lab.