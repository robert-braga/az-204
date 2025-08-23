//
// This function is triggered by events from an Event Hub, processes them,
// and publishes a new event to an Event Grid Topic if an anomaly is detected.
//
using System;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Azure;
using Azure.Messaging.EventGrid;
using Azure.Messaging.EventHubs;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

public class ProcessTelemetry
{
    private readonly ILogger<ProcessTelemetry> _logger;
    // The EventGridPublisherClient is created once and reused.
    private static readonly EventGridPublisherClient _eventGridClient = new(
        new Uri(Environment.GetEnvironmentVariable("EventGridTopicEndpoint")),
        new AzureKeyCredential(Environment.GetEnvironmentVariable("EventGridTopicAccessKey"))
    );

    public ProcessTelemetry(ILogger<ProcessTelemetry> logger)
    {
        _logger = logger;
    }

    [Function("ProcessTelemetry")]
    public async Task Run([EventHubTrigger("%EventHubName%", Connection = "ehnsrbrtelemetry2025_ListenRule_EVENTHUB")] EventData[] events)
    {
        _logger.LogInformation($"Processing a batch of {events.Length} events.");

        foreach (var eventData in events)
        {
            try
            {
                string messageBody = Encoding.UTF8.GetString(eventData.Body.ToArray());
                var sensorReading = JsonSerializer.Deserialize<SensorReading>(messageBody);

                if (sensorReading != null && sensorReading.temperature > 50.0)
                {
                    _logger.LogWarning($"High temperature detected! Sensor: {sensorReading.sensorId}, Temp: {sensorReading.temperature}");

                    // Create a new event to publish to Event Grid
                    var alertEvent = new EventGridEvent(
                        subject: $"sensor-alerts/{sensorReading.sensorId}",
                        eventType: "Sensor.HighTemperatureDetected",
                        dataVersion: "1.0",
                        data: sensorReading // The event payload will be the original sensor data
                    );

                    // Send the event to the Event Grid Topic
                    await _eventGridClient.SendEventAsync(alertEvent);
                    _logger.LogInformation($"Published HighTemperatureDetected event for sensor {sensorReading.sensorId}.");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error processing event: {ex.Message}");
            }
        }
    }
}

public record SensorReading(string sensorId, double temperature, double humidity, DateTime timestamp);