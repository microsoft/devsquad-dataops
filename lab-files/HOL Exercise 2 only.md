## Exercise 2: Infrastructure As Code

Duration: 30 minutes

In this exercise, you will explore and understand the structure and contents of the IaC folder, which contains all the scripts and templates necessary to correctly perform this and other exercises in this lab, using a best practices model.

### Technology Overview - Infrastructure As Code Practice

Infrastructure as Code (IaC) is the management of infrastructure (networks, virtual machines, load balancers, and connection topology) in a descriptive model, using the same versioning as DevOps team uses for source code. Like the principle that the same source code generates the same binary, an IaC model generates the same environment every time it is applied. IaC is a key DevOps practice and is used in conjunction with continuous delivery. (https://docs.microsoft.com/en-us/devops/deliver/what-is-infrastructure-as-code)

### Technology Overview - Azure Resource Manager Templates

To implement infrastructure as code for your Azure solutions, use Azure Resource Manager templates (ARM templates). The template is a JavaScript Object Notation (JSON) file that defines the infrastructure and configuration for your project. The template uses declarative syntax, which lets you state what you intend to deploy without having to write the sequence of programming commands to create it. In the template, you specify the resources to deploy and the properties for those resources. (https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/overview)

### Task 1: Understanding the IaC folder

In this task you will explore and understand the folder structure and scripts, templates contained in it for execution in IaC.

To proceed with the execution of the other exercises below, you must understand the structure of the "infrastructure-as-code" folder, as well as its content of templates and scripts.

![](media/infrastructure-as-code-folder.PNG 'infrastructure as code')

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

# File: azuredeploy.json

![](media/iac-folder-infrastructure.PNG 'infrastructure-folder')

Main template, with declared parameters, variables and resources. Here we use linkedTemplates.
*NOTE*: We have the option of using separate parameter files as a good practice when using IaC templates, without the need to change directly in the main template.


# Folder: linkedTemplates

![](media/iac-folder-linkedtemplates.PNG 'linkedTemplate-folder')

In linkedTemplates we have templates with "parts" of declared resources that are not declared in the main Template, in order to reuse and can link with other templates.
*NOTE*: linkedTemplates is a widely used practice, for better organization and handling of templates of different types of resources and being able to link them to any template.


# Sub-Folders and Files: linkedTemplates

![](media/iac-folder-linkedtemplates-subfolders.PNG 'linkedTemplate-sub-folders')

# File: template.json (subfolders 1, 2, 3)

For each subfolder (1, 2, 3) we have this file "similar" to the azuredeploy.json file, but with the declaration being carried out only with the resources corresponding to the subfolder type, for example: subfolder compute, we have a template file. json with only compute-related resources declared which will link to the main template next (azuredeploy.json).

Computing resources: Virtual machine, network interface, Public IP, Key Vault, DataBricks, DataFactory
Data resources: DataLake Storage Account
ML resources: Machine Learning Services

Example of a resource declaration in this template.

![](media/iac-linkedtemplates-template-compute.PNG 'lkd-template-compute')

# File: compute.json, data.json (subfolder 4)

For subfolder 4 we have two templates named "compute" and "data" responsible and with declared instructions to apply and allow access to each resource to be created, correctly.

To apply a correct role and permission to a resource, Azure uses features from Azure Active Directory, such as Service Principal.

### Technology Overview - Azure AD Service Principal

An Azure service principal is an identity created for use with applications, hosted services, and automated tools to access Azure resources. This access is restricted by the roles assigned to the service principal, giving you control over which resources can be accessed and at which level. For security reasons, it's always recommended to use service principals with automated tools rather than allowing them to log in with a user identity. (https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli)

Example of a resource declaration in this template.

![](media/iac-service-principal.PNG 'iac-service-principal')


# Folder: parameters

![](media/iac-folder-parameters.PNG 'parameters-folder')

Parameters folder and directory with templates files with parameters and values to be used by linkedTemplates and main template, without the need to change directly in the main template.
*NOTE*: Using templates parameters is optional and can be used directly in the main template. However, following a model of good practice, the use separately is indicated.



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

