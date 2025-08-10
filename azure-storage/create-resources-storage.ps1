# This PowerShell script creates the resources for the app service, step by step   

$resourceGroupName="rg-rbr-storage"
$location="northeurope"
$appServicePlanName="asp-rbr-storage-s1"
$webAppName="webapp-rbr-storage-$(Get-Random -Minimum 1000 -Maximum 9999)"
$storageName = "stazrbrstorage$(Get-Random -Minimum 1000 -Maximum 9999)"
$cosmosName = "cosmos-rbr-$(Get-Random -Minimum 1000 -Maximum 9999)"

# Set defaults to not type them after in each command
az configure --defaults location=$location group=$resourceGroupName

# Create resources
Write-Host "1. Create resource group ($resourceGroupName)..." -ForegroundColor Green
az group create --name $resourceGroupName --tags "project=az204-prep-storage" "owner=rbr"

Write-Host "2. Create App Service Plan ($appServicePlanName) - with S1 sku ..." -ForegroundColor Green
az appservice plan create --name $appServicePlanName --sku S1 --is-linux 

Write-Host "3. Create Web App ($webAppName)..." -ForegroundColor Green
az webapp create --name $webAppName --plan $appServicePlanName --runtime "DOTNETCORE:9.0"

Write-Host "4. Create storage account..."
az storage account create --name $storageName --sku Standard_LRS

Write-Host "5. Create Cosmos account (NoSQL)..."
az cosmosdb create --name $cosmosName

Write-Host "6. Create Cosmos DB database and container..."
az cosmosdb sql database create --account-name $cosmosName --name "ProductsDb"
# We choose '/category' as the partition key for our container.
az cosmosdb sql container create --account-name $cosmosName --database-name "ProductsDb" --name "Items" --partition-key-path "/category"

# get connection strings
$storageConnectionString = az storage account show-connection-string --name $storageName -o tsv
$cosmosConnectionString = az cosmosdb keys list --name $cosmosName --type connection-strings --query "connectionStrings[0].connectionString" -o tsv


Write-Host "7. Configuring App Settings in Azure..."
az webapp config appsettings set --name $webAppName --settings "StorageConnectionString=$storageConnectionString" "CosmosConnectionString=$cosmosConnectionString"



Write-Host "Infrastructure deployment complete!" -ForegroundColor Cyan
Write-Host "For local testing, add these to your appsettings.Development.json or user secrets:"
Write-Host "StorageConnectionString = `"$storageConnectionString`""
Write-Host "CosmosConnectionString = `"$cosmosConnectionString`""