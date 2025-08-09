using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace MyAzureFunctions;

public class ProcessUploadedFile
{
    private readonly ILogger<ProcessUploadedFile> _logger;

    public ProcessUploadedFile(ILogger<ProcessUploadedFile> logger)
    {
        _logger = logger;
    }

    [Function("ProcessUploadedFile")]
    public void Run(
            // This attribute defines the trigger.
            // It watches the 'samples-workitems' container for new blobs.
            // The 'Connection' property refers to the connection string key in our settings.
            [BlobTrigger("samples-workitems/{name}", Connection = "AzureWebJobsStorage")] byte[] myBlob,
            string name)
    {
        _logger.LogInformation($"C# Blob trigger function processed blob.\n Name: {name}\n Size: {myBlob.Length} Bytes");
    }
}