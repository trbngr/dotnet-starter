using Microsoft.Extensions.Configuration;
using Npgsql;

namespace demo.common.Configuration;

public record PostgresConfiguration(IConfiguration Configuration)
{
    public string ConnectionString => Configuration["Postgres:ConnectionString"] ??
                                      "Host=localhost;Username=postgres;Password=postgres;Database=demo;Port=5435;";
    
    public static implicit operator string(PostgresConfiguration cfg) => cfg.ConnectionString;
}