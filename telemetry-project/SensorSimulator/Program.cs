using System.Text;
using System.Text.Json;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;

const string eventHubConnectionString = "..."; //TODO: to move in Env variables

const string eventHubName = "sensors-data-stream";

Console.WriteLine("Starting simulator for sensor data...");

// creating a producer client needed to send data to the event hub
await using (var producerClient = new EventHubProducerClient(eventHubConnectionString, eventHubName))
{
    var random = new Random();
    int eventCount = 0;

    while (true)
    {
        try
        {
            using EventDataBatch batch = await producerClient.CreateBatchAsync();

            for (int i = 1; i <= 10; i++)
            {
                var sensorData = new
                {
                    sensorId = $"sensor-{i}",
                    temperature = random.NextDouble() * 50 + 10, // temp between 10 - 60
                    humidity = random.NextDouble() * 100, // humidity between 0 - 100
                    timestamp = DateTime.UtcNow
                };

                // Occasionally generate an anomaly for our later processing steps
                if (random.Next(1, 100) > 95) // 5% chance of an anomaly
                {
                    sensorData = sensorData with { temperature = random.NextDouble() * 50 + 51 }; // Temp over 50°C
                }

                var jsonMessage = JsonSerializer.Serialize(sensorData);

                // Create an EventData object from the JSON message
                var eventData = new EventData(Encoding.UTF8.GetBytes(jsonMessage));

                // Try to add the event to the batch. If the batch is full, this will return false.
                if (!batch.TryAdd(eventData))
                {
                    throw new Exception($"Event {sensorData.sensorId} is too large for the batch and cannot be sent.");
                }
            }

            await producerClient.SendAsync(batch);
            eventCount += 10;
            Console.WriteLine($"A batch of 10 events has been published. Total events sent: {eventCount}");
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"An error occurred: {ex.Message}");
            Console.ResetColor();
        }

        // wait 2 sec before sending another batch
        await Task.Delay(2000);
    }
}