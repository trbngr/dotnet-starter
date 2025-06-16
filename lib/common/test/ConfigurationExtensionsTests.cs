using Microsoft.Extensions.Configuration;

namespace demo.common.tests;

public class ConfigurationExtensionsTests
{
    [Fact]
    public void RabbitMqConfiguration_Default()
    {
        var configuration = new ConfigurationBuilder().Build();
        var rabbitmq = configuration.RabbitMq();
        Assert.Equal("amqp://localhost:5672", rabbitmq);
    }

    [Fact]
    public void RabbitMqConfiguration_Declared()
    {
        var values = new Dictionary<string, string?> { { "RabbitMq:ConnectionString", "amqp://remote:5672" } };

        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(values)
            .Build();

        var rabbitmq = configuration.RabbitMq();

        Assert.Equal("amqp://remote:5672", rabbitmq);
    }

    [Fact]
    public void PostgresConfiguration_Default()
    {
        var configuration = new ConfigurationBuilder().Build();
        var pg = configuration.Postgres();
        Assert.Equal("Host=localhost;Username=postgres;Password=postgres;Database=demo;Port=5435;",
            pg);
    }

    [Fact]
    public void PostgresConfiguration_Declared()
    {
        var values = new Dictionary<string, string?>
            { { "Postgres:ConnectionString", "Host=remote;Username=postgres;Password=postgres;Database=demo;" } };

        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(values)
            .Build();

        var pg = configuration.Postgres();

        Assert.Equal("Host=remote;Username=postgres;Password=postgres;Database=demo;", pg);
    }
}