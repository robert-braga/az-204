# This PowerShell script creates the resources for the app service, step by step   

$resourceGroupName="rg-rbr-webapp"
$location="northeurope"
$appServicePlanName="asp-rbr-webapp"
$randomSuffix = -join ((65..90) + (97..122) | Get-Random -Count 5 | ForEach-Object {[char]$_})
$webAppName="webapp-rbr-$randomSuffix"

# Set defaults to not type them after in each command
az configure --defaults $location=northeurope group=rg-rbr-webapp

# Create resources
Write-Host "1. Create resource group ($resourceGroupName)..."
az group create --name $resourceGroupName --tags "project=az204-prep" "owner=rbr"

Write-Host "2. Create App Service Plan ($appServicePlanName)..."
az appservice plan create --name $appServicePlanName --sku B1 --is-linux 

Write-Host "3. Create Web App ($webAppName)..."
az webapp create --name $webAppName --plan $appServicePlanName --runtime "DOTNETCORE:9.0"

Write-Host "4. Set configuration in Azure..."
az webapp config appsettings set --name $webAppName --settings "AppSettings:Greeting=Hello from Azure Configuration"


# Publish and deploy
Write-Host "5. Publish the .NET project..."
# navigate in the project folder, publish it and create the archive
Set-Location WebApiInAppService
dotnet publish -c Release -o ./publish

Compress-Archive -Path ./publish/* -DestinationPath ./deploy.zip -Force

Write-Host "6. Deploy the app in Azure..."
# deprecated -> az webapp deployment source config-zip --name $webAppName --src deploy.zip
az webapp deploy --name $webAppName --src-path ./deploy.zip

Write-Host "The deployment is done!" -ForegroundColor Green
Write-Host "App url: https://$webAppName.azurewebsites.net/home" 

# clear the local files created during deployment phase
Set-Location ..
Remove-Item -Path ".\WebApiInAppService\publish" -Recurse
Remove-Item -Path ".\WebApiInAppService\deploy.zip" -Recurse