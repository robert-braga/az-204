** command for setting defaults in azure cli, in order to no more write the location and resource-group**
az configure --defaults location=northeurope group=rg-rbr-storage

** add packages **
dotnet add package Azure.Storage.Blobs
dotnet add package Microsoft.Azure.Cosmos


** Creates a service principal with 'contributor' rights scoped to the resource group. **
The output is a JSON object that will be used as the authentication secret by the GitHub Actions pipeline.
```
az ad sp create-for-rbac --name "github-actions-az204-storage" --role "contributor" --scopes "/subscriptions/{subscription_id}/resourceGroups/rg-rbr-storage" --sdk-auth
```