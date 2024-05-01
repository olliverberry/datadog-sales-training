using LogGeneratorApi.Services;

namespace LogGeneratorApi;

public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        // Add services to the container.
        builder.Services.AddLogging(config =>
        {
            config.SetMinimumLevel(LogLevel.Information);
            config.AddJsonConsole(json =>
            {
                json.IncludeScopes = true;
                json.UseUtcTimestamp = true;
            });
        });
        builder.Services.AddHostedService<LogGenerator>();
        builder.Services.AddControllers();
        var app = builder.Build();

        // Configure the HTTP request pipeline.
        app.MapControllers();
        app.Run();
    }
}
