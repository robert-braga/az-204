using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;

namespace MyAzureFunctions;

public class GreetUser
{
    private readonly ILogger<GreetUser> _logger;

    public GreetUser(ILogger<GreetUser> logger)
    {
        _logger = logger;
    }

    [Function("GreetUser")]
    public async Task<HttpResponseData> Run([HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
    {
        _logger.LogInformation("C# HTTP trigger function processed a request.");

        // Read the 'name' parameter from the query string
        string name = req.Query["name"];

        var response = req.CreateResponse(HttpStatusCode.OK);
        response.Headers.Add("Content-Type", "text/plain; charset=utf-8");

        string responseMessage = string.IsNullOrEmpty(name)
            ? "Pass a name in the query string for a personalized response."
            : $"Hello, {name}. This function was triggered via HTTP.";

        await response.WriteStringAsync(responseMessage);
        return response;
    }
}