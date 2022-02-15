# DevSquad In a Day

### Index

<!-- TOC -->
- [DataOps hands-on lab step-by-step](#leveraging-azure-digital-twins-in-a-supply-chain-hands-on-lab-step-by-step)
  - [Abstract and learning objectives](#abstract-and-learning-objectives)
  - [Overview](#overview)
  - [Solution architecture](#solution-architecture)
  - [Requirements](#requirements)
  - [Before the hands-on lab](#before-the-hands-on-lab) (20 min)
  - [Exercise 1: Exploring Azure Data Services](#Exercise-1-Exploring-Azure-Data-Services) (30 min)
    - [Task 1: Azure Data Lake Storage](#Task-1-Azure-Data-Lake-Storage)
    - [Task 2: Azure Data Factory](#Task-2-Azure-Data-Factory)
    - [Task 3: Azure Databricks](#Task-3-Azure-Databricks)
  - [Exercise 2: Infrastructure As Code](#Exercise-2-Infrastructure-As-Code) (30 min)
    - [Task 1: Understanding the IaC folder]()
    - [Task 2: Creating a new sandbox environment with Powershell]()
    - [Task 3: Checklist of IaC best practices]()
  - [Exercise 3: Git Workflow and CI/CD](#Exercise-3-Git-Workflow-and-CI/CD) (45 min)
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
  - [Exercise 5: Testing](#exercise-5-testing) (25 min)
    - [Task 1: Understanding test types](#task-1-understanding-test-types)
    - [Task 2: Understanding BDD tests](#task-2-understanding-bdd-tests)
    - [Task 3: Developing a new test](#task-3-developing-a-new-test)
  - [Exercise 6: ML PLatform (optional)]() (30 min) (TBD)
  - [After the hands-on lab](#after-the-hands-on-lab)
    - [Task 1: Delete resource group](#task-1-delete-resource-group)
<!-- /TOC -->

# Hands-on lab step-by-step

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

!['Notebook activity'](media/mount-adls-1.png)

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

### Technology Overview - Azure Resource Manager Templates

To implement infrastructure as code for your Azure solutions, use Azure Resource Manager templates (ARM templates). The template is a JavaScript Object Notation (JSON) file that defines the infrastructure and configuration for your project. The template uses declarative syntax, which lets you state what you intend to deploy without having to write the sequence of programming commands to create it. In the template, you specify the resources to deploy and the properties for those resources. (https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/overview)

You can use pre-configured templates as the basis for your infrastructure provisioning using the repository on GitHub: (https://github.com/Azure/azure-quickstart-templates).

### Task 1: Understanding the IaC folder

In this task you will explore and understand the folder structure and scripts, templates contained in it for execution in IaC.

To proceed with the execution of the other exercises below, you must understand the structure of the "infrastructure-as-code" folder, as well as its content of templates and scripts.

!['infrastructure as code'](media/infrastructure-as-code-folder.png)

```
|infrastructure-as-code| ---> Principal folder
	|databricks|
		|dev|
			interactive.json
		|prod|
			interactive.json
		|qa|
			interactive.json
		|sandbox|
			core.json
	|infrastructure| ---> Azure Resource Manager templates
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
		|parameters| ---> Azure Resource Manager templates parameters
			parameters.dev.json
			parameters.dev.template.json
			parameters.prod.json
			parameters.prod.template.json
			parameters.qa.json
			parameters.qa.template.json
		azuredeploy.json
	|scripts| ---> Scripts file with objective to execute and create our infrastrucure with help from ARM templates
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
	|tests| ---> After of execution, these scripts can to validate if have anything incorrect in the process of creation
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

# Folder [infrastructure]

## File: azuredeploy.json

!['infrastructure-folder'](media/iac-folder-infrastructure.png)

Main template, with declared parameters, variables and resources. Here we use linkedTemplates.
*NOTE*: We have the option of using separate parameter files as a good practice when using IaC templates, without the need to change directly in the main template.

### Technology Overview - Azure Resource Manager Templates - Linked Templates

To deploy complex solutions, you can break your Azure Resource Manager template (ARM template) into many related templates, and then deploy them together through a main template. The related templates can be separate files or template syntax that is embedded within the main template. This article uses the term linked template to refer to a separate template file that is referenced via a link from the main template. It uses the term nested template to refer to embedded template syntax within the main template.

(https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/linked-templates?tabs=azure-powershell).

## Folder: linkedTemplates

!['linkedTemplate-folder'](media/iac-folder-linkedtemplates.png)

In linkedTemplates we have templates with "parts" of declared resources that are not declared in the main Template, in order to reuse and can link with other templates.
*NOTE*: linkedTemplates is a widely used practice, for better organization and handling of templates of different types of resources and being able to link them to any template.


## Sub-Folders and Files: linkedTemplates

!['linkedTemplate-sub-folders'](media/iac-folder-linkedtemplates-subfolders.png)

## File: template.json (subfolders 1, 2, 3)

For each subfolder (1, 2, 3) we have this file "similar" to the azuredeploy.json file, but with the declaration being carried out only with the resources corresponding to the subfolder type, for example: subfolder compute, we have a template file. json with only compute-related resources declared which will link to the main template next (azuredeploy.json).

Computing resources: Virtual machine, network interface, Public IP, Key Vault, DataBricks, DataFactory
Data resources: DataLake Storage Account
ML resources: Machine Learning Services

Example of a resource declaration in this template.

!['lkd-template-compute'](media/iac-linkedtemplates-template-compute.png)

## File: compute.json, data.json (subfolder 4)

For subfolder 4 we have two templates named "compute" and "data" responsible and with declared instructions to apply and allow access to each resource to be created, correctly.

To apply a correct role and permission to a resource, Azure uses features from Azure Active Directory, such as Service Principal.

### Technology Overview - Azure AD Service Principal

An Azure service principal is an identity created for use with applications, hosted services, and automated tools to access Azure resources. This access is restricted by the roles assigned to the service principal, giving you control over which resources can be accessed and at which level. For security reasons, it's always recommended to use service principals with automated tools rather than allowing them to log in with a user identity. (https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli)

Example of a resource declaration in this template.

!['iac-service-principal'](media/iac-service-principal.png)


## Folder: parameters

!['parameters-folder'](media/iac-folder-parameters.png)

Parameters folder and directory with templates files with parameters and values to be used by linkedTemplates and main template, without the need to change directly in the main template.
*NOTE*: Using templates parameters is optional and can be used directly in the main template. However, following a model of good practice, the use separately is indicated.

Example of a parameters declaration in this template.

!['iac-parameters'](media/parameters-dev-json.png)


# Folder [databricks]

In this file you will find declared settings related to the Databricks resource which will be used in executing the scripts (below) and provisioning your infrastructure, as well as its necessary resources.

!['iac-databricks'](media/iac-folder-databricks.png)

Example of a configuration declaration in this template.

!['iac-databricks-corejson'](media/iac-file-corejson-databricks.png)

# Folder [scripts]

In this folder you'll find all the scripts responsible for executing and creating resources, along with the ARM templates.
Some scripts are referenced with ARM templates, "calling" them to perform some necessary steps for the correct creation of resources and infrastructure.

However, we have a correct order for this execution as described in next task.

!['iac-scripts'](media/iac-scripts.png)


# Folder [tests]

After running using ARM templates, scripts and other configuration items and provisioning your infrastructure and resources, we must apply tests in order to validate if everything is ok.

These tests must be run through the scripts described below.

You can practice a little more on this topic in Exercise 5: Testing.

However, we have a correct order for this execution as described in next task.

!['iac-tests'](media/iac-folder-subfolder-tests.png)


### Task 2: Creating a new sandbox environment with Powershell

In this task you will learn how to create your first sandbox environment, with Azure Powershell scripts.

!['iac-ordem-scripts'](media/iac-ordem-scripts.png)

### Task 3: Checklist of IaC best practices

In this task you will understand the best practices in creating, executing and managing scripts and templates in IaC.
Using a checklist to review what has been or will be executed is extremely important, with the objective of validating and verifying what may be "missing" in your environment and that is essential for use.

At each complete rerun of the steps, you should use this checklist described below to "check" each item/box you have already validated and is ok.
In case of failure in one of the steps below, go back and validate the necessary to proceed.
NEVER "skip" a step in order to gain agility in the process. Each step is essential and important for you to have the most assertive environment possible and not have future problems :)

Whenever possible, review the reference documents listed at the end of these task for use of resources through best practice.

1. [ ] Does this code correctly implement the Azure resources and their properties?
2. [ ] Are the names of Azure resources correctly parameterized for all environments?
3. [ ] Are all Azure resources being implemented in the correct modules (e.g. data, compute)?
4. [ ] Are there acceptance tests that cover the newly added code and do they pass in the CI/CD pipelines?
5. [ ] Do the tests for this code correctly test the code?
6. [ ] Is the code documented well?
7. [ ] Have secrets been stripped before committing?
8. [ ] Is PII and EUII treated correctly? In particular, make sure the code is not logging objects or strings that might contain PII (e.g. request headers).
9. [ ] Is the deployment of the code scripted such that it is repeatable and ideally declarative?
10. [ ] Is the PR a relatively small change? Optimal PR sizes for code reviews are typically described in terms like embodying less than three days of work or having [200 or fewer changed lines of code](https://smallbusinessprogramming.com/optimal-pull-request-size/). If not, suggest smaller user stories or more frequent PRs in the future to reduce the amount of code being reviewed in one PR.

## Additional references

* [Azure Resource Manager Templates - Best Practices Guide](https://github.com/Azure/azure-quickstart-templates/blob/master/1-CONTRIBUTION-GUIDE/best-practices.md)
* [The PowerShell Best Practices and Style Guide](https://github.com/PoshCode/PowerShellPracticeAndStyle)
* [Effective code Reviews](https://www.evoketechnologies.com/blog/code-review-checklist-perform-effective-code-reviews/)
* [Terraform with Azure - Overview](https://docs.microsoft.com/en-us/azure/developer/terraform/overview)


## Exercise 3: Git Workflow and CI/CD

Duration: 45 minutes

## Exercise 4: Semantic Versioning of Data Engineering Libraries

Duration: 25 minutes

## Exercise 5: Testing

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

### Task 3: Developing a new test 
> This Task is Optional. It's objective is to get you familiarize on how Behave works and how it can be used to test Pipeline execution results.

**Pre-requisits:** Have an environment to run Python 3.4+, either on your local host or on a Virtual Machine like the "Data Sience Windows VM" on Azure.

Follow the instructions indicated [here](..\data-platform\src\bdd-adf-pipelines\README.md#motivation). After completion return to this page to continue with the lab.

## After the hands-on lab

Duration: 5 minutes

### Task 1: Delete resource group

1. In the [Azure Portal](https://portal.azure.com), delete the resource group you created for this lab.

You should follow all steps provided *after* attending the Hands-on lab.