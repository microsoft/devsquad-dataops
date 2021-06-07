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
  - [Before the hands-on lab](#before-the-hands-on-lab) (20~30 min) (5) (Renan)
  - [Exercise 1: Exploring Azure Data Services]() (30 min) (Owner: Maritza)
    - [Task 1: Azure Data Lake Storage]()
    - [Task 2: Azure Data Factory]()
    - [Task 3: Azure Databricks]()
  - [Exercise 2: Infrastructure As Code]() (30 min) (Owner: Jaque)
    - [Task 1: Understanding the IaC repository]()
    - [Task 2: Creating a new sandbox environment with Powershell]()
    - [Task 3: Checklist of IaC best practices]()
  - [Exercise 3: Git Workflow and CI/CD]() (45 min) (5) (Owner: Ana/Adrian)
    - [Task 1: Understanding all repositories]()
    - [Task 2: Understanding naming conventions for branches and commits]()
    - [Task 3: Release lifecycle strategy]()
    - [Task 4: Commiting and releasing a feature to ADF]()
    - [Task 5: CI Pipelines]()
    - [Task 6: CD Pipelines]()
    - [Task 7: Checklist of branching strategy (?) racionality]()
  - [Exercise 4: Semantic Versioning of Data Engineering Libraries]() (25 min) (Owner: Leandro)
    - [Task 1: Building custom libraries for data engineering]()
    - [Task 2: The Git workflow for data]()
    - [Task 3: Creating a new PR for the custom library]()
    - [Task 4: Custom libraries checklist]()
  - [Exercise 5: Testing]() (20 min) (2) (Owner: Jesus)
    - [Task 1: Understanding test types]()
    - [Task 1: Understanding BDD tests]()
    - [Task 2: Developing a new test]()
  - [Exercise 6: ML PLatform (optional)]() (30 min) (TBD)
  - [After the hands-on lab](#after-the-hands-on-lab)
    - [Task 1: Delete resource group](#task-1-delete-resource-group)
<!-- /TOC -->


## Personal Preferences

- Maritza: Exercise 1 and 6
- Jaqueline: Exercise 2 and 3
- Leandro: Exercise 1 and 4
- Jesus: Exercise 5
- Adrian: Exercise 3 and 6
- Ana: Exercise 3 and 6


# Leveraging Azure Digital Twins in a supply chain hands-on lab step-by-step

## Abstract and learning objectives

...

At the end of this hands-on lab, you will be better able to implement an end-to-end Data Engineering pipeline leveraging DataOps & Software Engineering best practices.

## Overview

...

## Solution architecture

Show the architecture of the final solution.

Explain each one of the repos that will be user for this workshop:
- IaC
- Data Platform
- ML Platform
- Docs

## Requirements

Add Requirements.

## Before the hands-on lab

Refer to the Before the hands-on lab setup guide manual before continuing to the lab exercises.

## Exercise 1: Authoring Digital Twins Definition Language (DTDL) models

Duration: 30 minutes


### Task 1: The components of a model



### Task 2: Ontologies overview



## After the hands-on lab

Duration: 5 minutes

### Task 1: Delete resource group

1. In the [Azure Portal](https://portal.azure.com), delete the resource group you created for this lab.

You should follow all steps provided *after* attending the Hands-on lab.