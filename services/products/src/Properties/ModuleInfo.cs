// ReSharper disable CheckNamespace
[assembly: HotChocolate.Module("ProductsModule")]
namespace demo;
public static class ProductsModule
{
    public static void AddProductsModule(this Wolverine.WolverineOptions options) =>
        options.Discovery.IncludeAssembly(typeof(ProductsModule).Assembly);
}