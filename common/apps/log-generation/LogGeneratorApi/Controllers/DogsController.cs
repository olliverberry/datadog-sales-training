using LogGeneratorApi.Dogs;
using Microsoft.AspNetCore.Mvc;

namespace LogGeneratorApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DogsController : ControllerBase
{
    private static readonly List<Dog> _mockDogs = new()
    {
        new Dog
        {
            Age = 13,
            Breeds = new()
            {
                "springer spaniel",
            },
            Name = "lily",
            Weight = 35,
            Colors = new()
            {
                "black",
                "white",
            },
        },
        new Dog
        {
            Age = 12,
            Breeds = new()
            {
                "springer spaniel",
            },
            Name = "lincoln",
            Weight = 40,
            Colors = new()
            {
                "liver",
                "white",
            },
        },
        new Dog
        {
            Age = 13,
            Breeds = new()
            {
                "german sherpherd",
                "border collie",
            },
            Name = "lily",
            Weight = 35,
            Colors = new()
            {
                "black",
                "white",
            },
        }
    };

    [HttpGet]
    public IEnumerable<Dog> GetDogs()
    {
        return _mockDogs;
    }
}
