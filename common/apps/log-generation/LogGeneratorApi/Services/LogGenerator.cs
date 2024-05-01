namespace LogGeneratorApi.Services;

public class LogGenerator : BackgroundService
{
    private static readonly List<string> _mockMessages = new()
    {
        "[INFO] | Requesting starting at path: GET /api/dogs.",
        "[DEBUG] | Request finished at path: GET /api/dogs. time: 50ms.",
        "[TRACE] | Executing action at Api.Controllers.GetDogs.",
        "[INFO] | Requesting starting at path: GET /api/dogs/{id}.",
        "[DEBUG] | Request finished at path: GET /api/dogs/{id}. time: 50ms.",
        "[TRACE] | Executing action at Api.Controllers.GetDogById.",
        "[WARN] | Unable to find dog with id: 1.",
        "[INFO] | Requesting starting at path: DELETE /api/dogs/{id}.",
        "[DEBUG] | Request finished at path: DELETE /api/dogs/{id}. time: 50ms.",
        "[TRACE] | Executing action at Api.Controllers.DeleteDogById.",
        "[DEBUG] | Successfully delete dog with id: 1 from the database.",
        "[INFO] | Requesting starting at path: POST /api/dogs/{id}.",
        "[DEBUG] | Request finished at path: POST /api/dogs/{id}. time: 50ms.",
        "[TRACE] | Executing action at Api.Controllers.CreateDog.",
        "[ERROR] | Unexpected error occurred while create dog with id: 10. Exception: duplication key exception",
    };

    private readonly ILogger<LogGenerator> _logger;

    public LogGenerator(ILogger<LogGenerator> logger)
    {
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken cancellationToken)
    {
        while (!cancellationToken.IsCancellationRequested)
        {
            foreach (var message in _mockMessages)
            {
                _logger.LogInformation(message);
            }

            await Task.Delay(5000, cancellationToken);
        }
    }
}