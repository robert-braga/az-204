Write-Host "Deleting the resource group..."
az group delete --name rg-rbr-webapp --yes --no-wait
az group delete --name rg-rbr-webapp-cicd --yes --no-wait
