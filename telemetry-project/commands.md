I will create here a project which consists in more parts:

1. .NET Console project which simulates more sensors which send data to an Event Hub - a data stream (part of an Event Hub Namespace)

2. An Azure Function which is triggered when new data is inserted in the Event Hub. It will analyze the data, and in case of anomalies, it sends a notification in the Event Grid 
    - a function is the perfect type of consumer because it stays in stand-by and is turned on when new data comes in
    - I could send an email or sms directly from the function, but I want to assure loose-coupling between actions.

    - with next, I can set the seetings on the function, but I did it manually in Environment variables screen on Azure Portal 
    az functionapp config appsettings set --name <Your-Function-App-Name> --settings "" "" ""

3. 
