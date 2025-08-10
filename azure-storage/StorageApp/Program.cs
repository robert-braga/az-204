using System.Runtime.InteropServices;
using Azure.Storage.Blobs;
using Microsoft.Azure.Cosmos;
using Microsoft.Azure.Cosmos.Serialization.HybridRow;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

// Register BlobServiceClient and CosmosClient in DI container using the connection strings set in Azure App Settings or appsettings.json

// Get connection strings from configuration (Azure App Settings or appsettings.json)
var blobConnectionString = builder.Configuration["StorageConnectionString"];
var cosmosConnectionString = builder.Configuration["CosmosConnectionString"];

// Register BlobServiceClient for dependency injection
builder.Services.AddSingleton(x => new BlobServiceClient(blobConnectionString));

// Register CosmosClient for dependency injection
builder.Services.AddSingleton(x => new CosmosClient(cosmosConnectionString));

var app = builder.Build();

// Configure the HTTP request pipeline.

app.UseHttpsRedirection();

var webApi = app.MapGroup("/home");

webApi.MapGet("/", () => Results.Ok("Hello from App Service!"));

webApi.MapGet("/config", (IConfiguration configuration) =>
{
    var greeting = configuration["Greeting"];
    if(string.IsNullOrWhiteSpace(greeting))
    {
        return Results.NotFound("Configuration value not found in AppService.");
    }

    return Results.Ok($"Configuration value found: {greeting}");
}
);

app.MapPost("/api/files", async (BlobServiceClient blobServiceClient, IFormFile file) =>
{
    if (file == null || file.Length == 0)
    {
        return Results.BadRequest("No file uploaded.");
    }

    string containerName = "uploads";

    // reference to a container client
    var containerClient = blobServiceClient.GetBlobContainerClient(containerName);

    // create container client
    await containerClient.CreateIfNotExistsAsync();

    var blobClient = containerClient.GetBlobClient(file.FileName);

    await using (var stream = file.OpenReadStream())
    {
        await blobClient.UploadAsync(stream);
    }

    return Results.Ok(new { fileName = file.FileName, url = blobClient.Uri.AbsoluteUri });
})
.DisableAntiforgery();


app.MapGet("api/products", async (CosmosClient cosmosClient) =>
{
    string databaseName = "ProductsDb";
    string containerName = "Items";

    var cosmosContainer = cosmosClient.GetContainer(databaseName, containerName);

    var sqlQueryText = "SELECT * FROM c";
    var queryDefinition = new QueryDefinition(sqlQueryText);

    var queryResultSetIterator = cosmosContainer.GetItemQueryIterator<Product>(queryDefinition);

    var products = new List<Product>();
    while (queryResultSetIterator.HasMoreResults)
    {
        var currentResultSet = await queryResultSetIterator.ReadNextAsync();
        products.AddRange(currentResultSet);
    }

    return Results.Ok(products);
});

app.MapPost("api/products", async (CosmosClient cosmosClient, Product product) =>
{
    string databaseName = "ProductsDb";
    string containerName = "Items";

    var cosmosContainer = cosmosClient.GetContainer(databaseName, containerName);

    var response = await cosmosContainer.CreateItemAsync(product, new PartitionKey(product.category));

    return Results.Created($"api/products/{product.id}", response.Resource);
});


app.Run();

public record Product (string id, string category, string name, decimal price);
