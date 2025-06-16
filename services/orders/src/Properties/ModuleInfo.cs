// ReSharper disable CheckNamespace
[assembly: HotChocolate.Module("OrdersModule")]
namespace demo;
public static class OrdersModule
{
    public static void AddOrdersModule(this Wolverine.WolverineOptions options) =>
        options.Discovery.IncludeAssembly(typeof(OrdersModule).Assembly);
}