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
  - [Exercise 5: Testing](#exercise-5-testing) (25 min)
    - [Task 1: Understanding test types](#task-1-understanding-test-types)
    - [Task 2: Understanding BDD tests](#task-2-understanding-bdd-tests)
    - [Task 3: Developing a new test](#task-3-developing-a-new-test)
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

![](media/high-level-overview-dataops.png 'Solution Architecture')

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




## Exercise 2: Infrastructure As Code

Duration: 30 minutes

In this exercise, you will explore and understand the structure and contents of the IaC folder, which contains all the scripts and templates necessary to correctly perform this and other exercises in this lab, using a best practices model.

### Technology Overview - Infrastructure As Code Practice

Infrastructure as Code (IaC) is the management of infrastructure (networks, virtual machines, load balancers, and connection topology) in a descriptive model, using the same versioning as DevOps team uses for source code. Like the principle that the same source code generates the same binary, an IaC model generates the same environment every time it is applied. IaC is a key DevOps practice and is used in conjunction with continuous delivery. (https://docs.microsoft.com/en-us/devops/deliver/what-is-infrastructure-as-code)

### Task 1: Understanding the IaC folder

In this task you will explore and understand the folder structure and scripts, templates contained in it for execution in IaC.

To proceed with the execution of the other exercises below, you must understand the structure of the "infrastructure-as-code" folder, as well as its content of templates and scripts.

![](media/infrastructure-as-code-folder.PNG 'infrastructure as code')

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

![](media/compute-template-json.PNG 'compute-linkedTemplate')

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

![](media/parameters-dev-json.PNG 'parameters-dev-json')

### Task 2: Creating a new sandbox environment with Powershell

In this task you will learn how to create your first sandbox environment, with Azure Powershell scripts.

### Task 3: Checklist of IaC best practices

In this task you will understand the best practices in creating, executing and managing scripts and templates in IaC.

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


## After the hands-on lab

Duration: 5 minutes

### Task 1: Delete resource group

1. In the [Azure Portal](https://portal.azure.com), delete the resource group you created for this lab.

You should follow all steps provided *after* attending the Hands-on lab.