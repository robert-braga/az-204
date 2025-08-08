var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

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

app.Run();