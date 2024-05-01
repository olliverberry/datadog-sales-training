namespace LogGeneratorApi.Services;

public class LogGenerator : BackgroundService
{
    private static readonly Dictionary<LogLevel, List<string>> _logLevelToMockMessages = new()
    {
        [LogLevel.Error] = new() 
            { 
                "Unexpected error occurred while create dog with id: 10. Exception: duplication key exception", 
            },
        [LogLevel.Warning] = new()
            {
                "Unable to find dog with id: 1.",
            },
        [LogLevel.Information] = new()
            {
                "Requesting starting at path: GET /api/dogs.",
                "Requesting starting at path: GET /api/dogs/{id}.",
                "Requesting starting at path: DELETE /api/dogs/{id}.",
                "Requesting starting at path: POST /api/dogs/{id}.",
            },
        [LogLevel.Debug] = new()
            {
                "Request finished at path: GET /api/dogs. time: 50ms.",
                "Request finished at path: GET /api/dogs/{id}. time: 50ms.",
                "Request finished at path: DELETE /api/dogs/{id}. time: 50ms.",
                "Successfully deleted dog with id: 1 from the database.",
                "Request finished at path: POST /api/dogs/{id}. time: 50ms.",
            },
        [LogLevel.Trace] = new()
            {
                "Executing action at Api.Controllers.GetDogs.",
                "Executing action at Api.Controllers.GetDogById.",
                "Executing action at Api.Controllers.DeleteDogById.",
                "Executing action at Api.Controllers.CreateDog.",
            },
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
            foreach (var (level, messages) in _logLevelToMockMessages)
            {
                foreach (var message in messages)
                {
                    _logger.Log(level, message);
                }
                await Task.Delay(5000, cancellationToken);
            }
        }
    }
}