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
