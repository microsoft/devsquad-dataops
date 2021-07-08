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
  - [Exercise 5: Testing](#Exercise-5-Testing) (25 min) (Owner: Jesus)
    - [Task 1: Understanding test types]()
    - [Task 2: Understanding BDD tests]()
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


## Exercise 1: Exploring Azure Data Services

Duration: 20 minutes

In this exercise, you will explore the main resources that have been deployed in your Azure Subscription.

The resource groups rerg-dataops-data-dev and rg-dataops-compute-dev contain data and compute services respectively.  

![](media/resource-groups.png 'Resource groups')

The rg-dataops-data resource group contains a [Data Lake Storage] (https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-introduction) and a [Blob Storage] (https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-overview) 

![](media/rg-dataops-data-dev.png 'Resource group: Data')

The resource group rg-dataops-compute contains an instance of [Azure Data Factory] (https://docs.microsoft.com/en-us/azure/data-factory/) and [Azure Databricks] (https://docs.microsoft.com/en-us/azure/databricks/)

![](media/rg-dataops-compute-dev.png 'Resource group: Compute')

### Technology Overview 

Azure Databricks and Azure Data Lake enable modern data architectures simplifying and accelerating the data processing at any scale.

Azure Data Factory loads raw data into Azure Blob Storage and Azure Databricks processes the data and organize it into layers: landing, refined, trusted

Azure Delta Lake forms the curated layer of the data lake. It stores the refined data in an open-source format

### Task 1: Explore Azure Blob Storage

In this task, you will explore the Azure Blob Storage instance. 

1. Open the Azure Portal and navigate to the rg-dataops-data resource group and select the stgdataopseastus2dev Azure Blob Storage. 

2. On the overview blade, select Containers

![](media/stgdataopseastus2dev.png 'Blob Storage Overview')

3. Select and open the flights-data container.

![](media/stgdataopseastus2dev-containers.png 'Containers')

4. Review the CSV files. Select the CSV file and download it. 

![](media/stgdataopseastus2dev-airport-metadata.png 'Files')

### Task 2: Explore Azure Data Lake Storage

In this task, you will explore the layers defined to organize the data into the Data Lake. The landing layer is for raw ingestion, and trusted layer is for the filtered and cleaned data.  

1. Open the Azure Portal and navigate to the rg-dataops-data resoruce group and select the Azure Data Lake instance lakedataopseastus2dev. 

2. On the Overview blade, select Containers

![](media/lakedataopseastus2dev-overview.png 'Data Lake overview')

3. Select and open the landing layer container.

![](media/lakedataopseastus2dev-layers.png 'Containers')

4. Select and open the directories airport-metada, flight-delays, flight-weather. They will contain CSV files with the infomation about airports, flights and weather. 

![](media/lakedataopseastus2dev-layer-landing.png 'Landing layer')

### Task 3: Azure Databricks
 
In this task, you will explore the Azure Databricks instance dbw-dataops-eastus2-dev. This resource contains notebooks with code to prepare and clean the data. 

1. Navigate to the Azure Databricks instance dbw-dataops-eastus2-dev and Launch the Workspace. 

![](media/dbw-dataops-eastus2-dev-overview.png 'Databricks overview')

2. Navigate to the Workspace hub (2). Open the folders shared with you (if someone share wiht you the databricks instance) or seek your user in Users (3). Open the DataOps Folder (4) and select the notebook named 01 ADLS Mount (5).  

![](media/dbw-dataops-eastus2-dev-ws.png 'Databricks workspace')

3. To run the notebook you need attach a cluster from the list (1) or create a new one if you don't have clusters deployed. 

![](media/notebook-01-adls-mount.png 'Attach a cluster')

3.1 Provide a name for the new cluster, establish the cluster setting and select Create Cluster.

![](media/dbw-dataops-new-cluster.png 'Creating a cluster')

3.2 Navigate back to the notebook named 01 ADLS Mount and attach the cluster

![](media/dbw-dataops-attaching-cluster.png 'Creating a cluster') .PNG 

4. Select Run Cell or Crt + Enter to run the cell and amount the Azure Data Lake. 
This code is to mount the Azure Data Lake Storage Gen2 account to Databricks File System. For the authentication, it uses Key Vault and OAuth 2.0.

![](media/notebook-01-adls-runcell.png 'Run')  

5. Navigate back to the notebook named 02 One Notebook to Rule Them All.

5.1 Run the cells to import the libraries that you will use to process and transform the data.

![](media/02-One-Notebook-to-Rule-Them-All-1.png 'Run')  

5.2 Read the file FlightDelaysWithAirportCodes.csv from the landing layer (1), transform the data (2), and create the a local table called flight_delays_with_airport_codes from the flight_delays_df Dataframe (3).  

![](media/02-One-Notebook-to-Rule-Them-All-2.png 'Run') 

5.3 Select clean columns to generate clean data (1) and save the clean data as a global table called flight_delays_clean (2). 

![](media/02-One-Notebook-to-Rule-Them-All-3.png 'Run') 

5.4 To see the created table: Click Data in the sidebar (1). In the databases folder, click on the default database (2). Open Tables Folder and Click the table name.  

![](media/globaltable-flight_delays_view.png 'Run') 

5.5 Navigate back to the notebook. Run cells 9, 10 and 11 to prepare the weather data. Cell 9 reads raw data from landing layer and create a local table called flight_weather_with_airport_code. Cell 10 transforms data and Cell 11 creates a global table called flight_weather_clean.

![](media/02-One-Notebook-to-Rule-Them-All-4.png 'Run') 

5.5 Run the rest of cells. Cell 14 copies clean data of flight dealys and weather into the trusted layer of the data lake (1). Cell 16 saves data of airports with the delayes into the logs folder as CSV file (trusted layer) (2). Finally,the path of the CSV file will be the notebook output (3).

![](media/02-One-Notebook-to-Rule-Them-All-5.png 'Run') 

### Task 4: Azure Data Factory

In this task, you will explore the adf-dataops-eastus2-dev Azure Data Factory instance. 

1. Navigate to the adf-dataops-eastus2-dev Azure Data Factory instance and launch the workspace (Author & Monitor). 

![](media/adf-dataops-eastus2-dev-overview.png 'Azure Data Factory Overview')

2. Navigate to the Author hub.

![](media/adf-dataops-eastus2-dev-workspace1.png 'Azure Data Factory Hub')

3. You will find the pipeline ProcessFlightDelaysData and 6 datasets. The pipeline contains the activities to copy data from the XXXXXXXSource datasets into the XXXXXXSink datasets.

![](media/adf-dataops-eastus2-dev-author.PNG 'Author Hub')

4. Open the pipeline ProcessFlightDelaysData and review the settings of the activities:
- Copy Airport Codes Data
- Copy Flights Delays  Data
- Copy Flights Weather Data
- Mount ADLS
- Transform Flights Data

![](media/adf-dataops-eastus2-dev-process-data.PNG 'Pipeline')

4.1. Select the Copy Airport Codes Data (1). Select the Source Tab (2) and Click on Open to see the settings of the AirportCodesSource dataset (3).

![](media/copy-airport-codes.PNG 'Copy Airport Codes Data')

4.2  Select Edit to review the Azure blob Storage linked service (1). View the file path that you want to copy (2). Select Browse to navigate into the stgdataopseastus2dev Azure Blob Storage instance (3) and Select the file path.  

![](media/airport-codes-source-csv.PNG 'Airport Codes Source dataset')

4.3 Navigate back to the Copy Airport Codes Data Activity in the pipeline ProcessFlightDelaysData. Select the Sink tab (1) and Click on Open to see the setting of the AirportCodesSink dataset (2).

![](media/copy-airport-codes-sink.PNG 'Sink')

4.4. Select Edit to review the Azure Data Lake linked service (1). View the layer  where you will copy the data (2). Select Browse to navigate into the lakedataopseastus2dev Azure Data Lake instance (3) and select the  layer (4).  

![](media/airport-codes-sync.PNG 'Airport dataset')

5. Repeat the steps 4.1 - 4.4 for the Copy Flights Delays Data and Copy Flights Weather Data activities.

6. Navigate back to the pipeline and select the notebook activity Mount ADLS. Select the Azure Databricks tab (1) and click on Edit to view the settings of the linked service of the Databricks instance.

![](media/mount-adls-1.PNG 'notebook activity')

7. Select the settings tab of the notebook activity to configure the notebook to run in the databricks instance (1). In the Notebook path, indicate the path of the notebook to run (2). Select Browse if you want to explore the available notebooks (3) and explore the available folders in the Databricks instance (4). Select Open to open the Databricks workspace. 

8. Repeat the steps 6 and 7 to explore the Notebook Activity Transform Flight Data. 

![](media/mount-adls-2.PNG 'notebook activity')

9. OPTIONAL - Navigate back to the pipeline and run it. 

![](media/pipeline-trigger.PNG 'Execute pipeline')

9.1 Navigate to the Data Lake. Follow the file path that you indicated in the step 4.4. You will find the CSV file just copied. 

![](media/lakedataopseastus2dev-airport-metadata.png 'Exploring Data Lake')

## Exercise 2: Infrastructure As Code

Duration: 30 minutes

In this exercise, you will explore and understand the structure and contents of the IaC folder, which contains all the scripts and templates necessary to correctly perform this and other exercises in this lab, using a best practices model.

### Technology Overview 

Infrastructure as Code (IaC) is the management of infrastructure (networks, virtual machines, load balancers, and connection topology) in a descriptive model, using the same versioning as DevOps team uses for source code. Like the principle that the same source code generates the same binary, an IaC model generates the same environment every time it is applied. IaC is a key DevOps practice and is used in conjunction with continuous delivery. (https://docs.microsoft.com/en-us/devops/deliver/what-is-infrastructure-as-code)

### Task 1: Understanding the IaC folder

In this task you will explore and understand the folder structure and scripts, templates contained in it for execution in IaC.

### Task 2: Creating a new sandbox environment with Powershell

In this task you will learn how to create your first sandbox environment, with Azure Powershell scripts.

### Task 3: Checklist of IaC best practices

In this task you will understand the best practices in creating, executing and managing scripts and templates in IaC.


## Exercise 3: Git Workflow and CI/CD

Duration: 45 minutes

## Exercise 4: Semantic Versioning of Data Engineering Libraries

Duration: 25 minutes

## Exercise 5: Testing

Duration: 25 minutes

## After the hands-on lab

Duration: 5 minutes

### Task 1: Delete resource group

1. In the [Azure Portal](https://portal.azure.com), delete the resource group you created for this lab.

You should follow all steps provided *after* attending the Hands-on lab.