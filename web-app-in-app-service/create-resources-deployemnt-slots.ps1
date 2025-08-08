# This PowerShell script creates the resources for the app service, step by step   

$resourceGroupName="rg-rbr-webapp-cicd"
$location="northeurope"
$appServicePlanName="asp-rbr-webapp-s1"
$webAppName="webapp-rbr-cicd-$(Get-Random -Minimum 1000 -Maximum 9999)"
$stagingSlotName="staging"

# Set defaults to not type them after in each command
az configure --defaults location=$location group=$resourceGroupName

# Create resources
Write-Host "1. Create resource group ($resourceGroupName)..." -ForegroundColor Green
az group create --name $resourceGroupName --tags "project=az204-prep-cicd" "owner=rbr"

Write-Host "2. Create App Service Plan ($appServicePlanName) - with S1 sku to support slots..." -ForegroundColor Green
az appservice plan create --name $appServicePlanName --sku S1 --is-linux 

Write-Host "3. Create Web App ($webAppName)..." -ForegroundColor Green
az webapp create --name $webAppName --plan $appServicePlanName --runtime "DOTNETCORE:9.0"

Write-Host "4. Creating the 'staging' Deployment Slot..." -ForegroundColor Green
az webapp deployment slot create --name $webAppName --slot $stagingSlotName

Write-Host "5. Set configuration in Azure on $stagingSlotName slot..." -ForegroundColor Green
az webapp config appsettings set --name $webAppName --slot $stagingSlotName --settings 'Greeting=Hello from Azure Configuration - Staging Slot'


# Publish and deploy
Write-Host "6. Publish the .NET project..." -ForegroundColor Green
# navigate in the project folder, publish it and create the archive
Set-Location WebApiInAppService
dotnet publish -c Release -o ./publish

Compress-Archive -Path ./publish/* -DestinationPath ./deploy.zip -Force

Write-Host "7. Deploy the app in Azure..." -ForegroundColor Green
# deprecated -> az webapp deployment source config-zip --name $webAppName --src deploy.zip
az webapp deploy --name $webAppName --src-path ./deploy.zip

Write-Host "The deployment is done!" -ForegroundColor Green
Write-Host "App url: https://$webAppName.azurewebsites.net/home" 

# clear the local files created during deployment phase
Set-Location ..
Remove-Item -Path ".\WebApiInAppService\publish" -Recurse
Remove-Item -Path ".\WebApiInAppService\deploy.zip" -Recurse