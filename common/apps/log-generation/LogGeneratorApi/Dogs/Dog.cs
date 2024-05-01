namespace LogGeneratorApi.Dogs;

public class Dog
{
    public int Age { get; set; }

    public string Name { get; set; } = string.Empty;

    public List<string> Colors { get; set; } = new();

    public double Weight { get; set; }

    public List<string> Breeds { get; set; } = new();
}