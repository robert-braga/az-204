$resourceGroupName = "rg-rbr-telemetry"
$location = "northeurope"
$eventHubNamespace = "ehns-rbr-telemetry-2025"
$eventHubName = "sensors-data-stream"
$functionStorageName = "staccrbrtelemetryfunc"
$functionAppName = "func-rbr-telemetry-processor"
$eventGridTopicName = "egt-rbr-hightemperature-alerts"

az configure --defaults group=$resourceGroupName location=$location

# --- Create Resources ---
Write-Host "1. Creating Resource Group..." -ForegroundColor Green
az group create --name $resourceGroupName

Write-Host "2. Creating Event Hubs Namespace..." -ForegroundColor Green
# We use the Standard SKU which is common for production workloads.
az eventhubs namespace create --name $eventHubNamespace --sku Standard

Write-Host "3. Creating the Event Hub inside the namespace..." -ForegroundColor Green
# By default, it's created with multiple partitions for scalability.
az eventhubs eventhub create --name $eventHubName --namespace-name $eventHubNamespace

Write-Host "4. Creating an authorization rule to get a connection string..." -ForegroundColor Green
# We create a specific rule with Send permissions for our sensors.
az eventhubs eventhub authorization-rule create --name "SendRule" `
    --eventhub-name $eventHubName `
    --namespace-name $eventHubNamespace `
    --rights "Send"

$connectionString = az eventhubs eventhub authorization-rule keys list --name "SendRule" `
    --eventhub-name $eventHubName `
    --namespace-name $eventHubNamespace `
    --query "primaryConnectionString" `
    --output tsv


Write-Host "5. Creating Storage Account for Function App..." -ForegroundColor Green
az storage account create --name $functionStorageName --sku Standard_LRS

Write-Host "6. Creating the Processor Function App..." -ForegroundColor Green
az functionapp create --name $functionAppName `
    --storage-account $functionStorageName `
    --consumption-plan-location $location `
    --runtime "dotnet-isolated" `
    --functions-version 4

Write-Host "7. Creating Event Grid Topic for alerts..." -ForegroundColor Green
az eventgrid topic create --name $eventGridTopicName

Write-Host "8. Creating an authorization rule with 'Listen' permission for the function"
az eventhubs eventhub authorization-rule create --name "ListenRule" `
    --eventhub-name $eventHubName `
    --namespace-name $eventHubNamespace `
    --rights "Listen"

$eventHubListenConnectionString = az eventhubs eventhub authorization-rule keys list --name "ListenRule" `
    --eventhub-name $eventHubName `
    --namespace-name $eventHubNamespace `
    --query "primaryConnectionString" `
    --output tsv

$topicEndpoint = (az eventgrid topic show --name $eventGridTopicName --query "endpoint" --output tsv)
$topicAccessKey = (az eventgrid topic key list --name $eventGridTopicName --query "key1" --output tsv)



Write-Host "Infrastructure deployment complete!" -ForegroundColor Cyan
Write-Host "We will need the following connection string for the sensor application:"
Write-Host $connectionString
Write-Host "`nProcessor Function App (next to its local.settings.json):"
Write-Host "EventHubConnectionString_Listen=`"$eventHubListenConnectionString`""
Write-Host "EventGridTopicEndpoint=`"$topicEndpoint`""
Write-Host "EventGridTopicAccessKey=`"$topicAccessKey`""