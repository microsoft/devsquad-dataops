# Motivation

Testing data pipelines has unique challenges that makes it different from testing traditional software. You have data pipelines that pulls data from many source systems, ensure data quality (i.e. ensure that bad data is identified, then blocked, scrubbed, fixed, or just logged), combines this data, transforms and scrubs it. Then the data is stored in some processed state for consumption by downstream systems, analytics platforms, or data scientists. These pipelines often process data from *hundreds* or even *thousands* of sources. You run your pipelines and get *several* million new rows in your consumption layer.

Then you create full end-to-end functional tests for the pipelines. The pipelines are getting more complex over time, and the tests are becoming harder to understand and maintain. Then you start thinking:

* How to make the tests as readable as possible?
* How to improve tests maintainability?
* *How to effectively communicate the **current behavior** of the data pipelines with the team or across teams?*

Leveraging the concepts of Behavior-Driven Development could be the answer for these questions. BDD uses **human-readable** descriptions of software user requirements as the basis for software tests, where we define a shared vocabulary between stakeholders, domain experts, and engineers. This process involves the definition of entities, events, and outputs that the users care about, and giving them names that everybody can agree on.

## Testing Strategy

### Language and Frameworks

Data engineers and data scientists are turning decisively to Python - according to the [O'Reilly annual usage analysis](https://www.oreilly.com/radar/oreilly-2020-platform-analysis/) - due to its applicability and its tools for data analysis and ML/AI.

For this reason, the tests in this repository are written in Python using the most used open-source BDD framework called [behave](https://github.com/behave/behave). The framework leverages the use of [Gherkin](https://cucumber.io/docs/gherkin/reference/) to write tests, a well-known language used in BDD designed to be human readable.

### Structure of tests

Essentially the test files are structured in two levels:

* **Features**: Files where we specify the expected behavior of the data pipelines based on the existing requirements that can be understood by all people involved (e.g. data engineers, data scientists, business analysts). The specifications are written in Gherkin format.
* **Steps**: Files where we implement the scenarios defined on feature files. These files are written in Python.

## Prerequisites

* An Azure account with an active subscription ([Create one for free](https://azure.microsoft.com/en-us/free/?ref=microsoft.com&utm_source=microsoft.com&utm_medium=docs&utm_campaign=visualstudio) 😁)
* [Python 3.4+](https://www.python.org/downloads/) installed and working on you developing environment. Use of Visual Studio Code is recomended.

## Getting Started

If using Visual Studio Code open a bash Terminal.
Navigate to the `src` directory under this current path (data-platform/src) and create a virtual environment:

```sh
python3 -m venv env
source env/bin/activate/scripts/activate
```

Navigate to the `bdd-adf-pipelines` directory and then install the required packages:

```sh
cd bdd-adf-pipelines
pip3 install -r requirements.txt
```

Create the following environment variables using the values for your lab Azure environment:

```sh
export CLIENT_ID="<your client id>"
export CLIENT_SECRET="<your client secret>"
export SUBSCRIPTION_ID="<your subscription id>"
export TENANT_ID="<your tenant id>"
export ADF_NAME="<adf name>"
export RESOURCE_GROUP_NAME="<client id>"
export STORAGE_ACCOUNT_NAME="<your storage account>"
export STORAGE_ACCOUNT_KEY="<your storeage account key>"
```

>The storage account was created on the Exercise 3, review Task 4 to see it's name and get the Accoutn Key from the Portal.

Then run the following command to start the BDD tests:

```sh
behave
```

The result should look similar to the next image:

![Behave Results](/lab-files/media/behave-results.png)

## References

* [The challenge of testing Data Pipelines](https://medium.com/slalom-build/the-challenge-of-testing-data-pipelines-4450744a84f1)
