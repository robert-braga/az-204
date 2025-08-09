# PowerShell script to create the resources in Azure for Azure functions project

$resourceGroupName = "rg-rbr-azfunctions"
$storageName = "strbrfuncs$(Get-Random -Minimum 1000 -Maximum 9999)"
$functionName = "func-rbr-$(Get-Random -Minimum 1000 -Maximum 9999)"
$location = "northeurope"

az configure --defaults group=$resourceGroupName location=$location

# --- Create Resources ---
Write-Host "1. Creating Resource Group..." -ForegroundColor Green
az group create --name $resourceGroupName

Write-Host "2. Creating Storage Account..." -ForegroundColor Green
# Azure Functions requires a storage account for state management and function code storage.
az storage account create --name $storageName --sku Standard_LRS

Write-Host "3. Creating Function App on a Consumption Plan..." -ForegroundColor Green
# A Consumption plan is serverless and bills per execution and memory usage.
az functionapp create --name $functionName `
                      --storage-account $storageName `
                      --consumption-plan-location $location `
                      --runtime "dotnet-isolated" `
                      --functions-version 4

Write-Host "4. Creating Blob Container for the trigger..." -ForegroundColor Green
# This is the container our 'ProcessUploadedFile' function will monitor.
$storageConnectionString = az storage account show-connection-string --name $storageName --query connectionString -o tsv
az storage container create --name "samples-workitems" --connection-string $storageConnectionString

# --- Output ---
Write-Host "Infrastructure deployment complete!" -ForegroundColor Cyan
Write-Host "I need to copy the connection string in local.settings.json" -ForegroundColor Blue
Write-Host $storageConnectionString