# AZ-204: Azure Developer Associate exam - projects created during preparation


## 1. Web App Deployment in a App Service Plan

This project demonstrates a professional setup for deploying a .NET Web API to Azure App Service, featuring a CI/CD pipeline with GitHub Actions and a safe deployment strategy using deployment slots.

### Key Features

- **Infrastructure as Code (IaC):** All Azure resources are defined and created using PowerShell scripts for consistency and repeatability.
- **CI/CD Pipeline:** A GitHub Actions workflow automatically builds the .NET project and deploys it to a 'staging' environment on every push to the `main` branch.
- **Zero-Downtime Deployments:** Uses a 'staging' deployment slot to validate changes before swapping into 'production', ensuring users experience no downtime.

### How It Works

1.  The `create-resources-deployemnt-slots.ps1` script provisions an Azure App Service with an S1 plan and a 'staging' deployment slot.
2.  A GitHub Actions workflow defined in `.github/workflows/deploy-staging.yaml` triggers on `git push`.
3.  The workflow builds the .NET project and deploys the artifacts to the **staging slot**.
4.  After manual verification on the staging URL, a **Swap** operation is performed in the Azure Portal to promote the new version to production.

### Learnings

- Implemented a secure connection between GitHub and Azure using a Service Principal stored in GitHub Secrets.
- Wrote a YAML file from scratch to define a CI/CD pipeline.
- Understood the practical benefits of deployment slots for safe, zero-downtime releases and easy rollbacks.
- Managed infrastructure (`S1` plan, slots) and application configuration (`appsettings`) via Azure CLI.


## 2. Azure functions project

This project demonstrates a setup for deploying a .NET Function App to Azure Functions.

### Key Features

- **Infrastructure as Code (IaC):** All Azure resources are defined and created using PowerShell scripts for consistency and repeatability.


### How It Works

1.  The `create-resources.ps1` script provisions an Azure Function App togheter with a storage account, for code storage and state management
2. The function app is created in a Consumption plan, the best solution for a dev/test project
3. Inside the storage account, I created a container which is the trigger for the 'ProcessUploadedFile' function.


### Learnings

- Every time when the URL foor the 'GreetUser' route is accessed, a trigger handles it and logs the information in Azure Log Monitor
- Every time a file is uploaded in the container created, a blob trigger activates the function which process the file.
- Azure Functions is based on the serverless model - pay depending on the use - and is the solution used for the pieces of code which must react when certain events happen


## 3. Azure storage project

This project demonstrates a setup for deploying a .NET Web App which uses Azure Blob Storage and Azure Cosmos DB to store the data and files

### Key Features

- **Infrastructure as Code (IaC):** All Azure resources are defined and created using PowerShell scripts for consistency and repeatability.


### How It Works

1.  The `create-resources-storage.ps1` script provisions an Web App which uses Azure Blob Storage for storing files and Azure Cosmos DB to store the data about products
2.  For the Azure Cosmos DB, I set the 'category' field as partition key in order to distribute the data on many phisycal partitions, a good solution for scalability and performance
