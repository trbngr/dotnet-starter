using HotChocolate.Language;
using HotChocolate.Types;

namespace demo.products.Types;

[ExtendObjectType(OperationType.Query)]
public class ProductsQueries
{
    public static Product[] GetProducts()
    {
        return
        [
            new Product
            {
                Id = 1,
                Name = "Product 1",
                Sku = "SKU1",
                Description = "Description 1",
                Price = 1.0m
            },
            new Product
            {
                Id = 2,
                Name = "Product 2",
                Sku = "SKU2",
                Description = "Description 2",
                Price = 2.0m
            },
            new Product
            {
                Id = 3,
                Name = "Product 3",
                Sku = "SKU3",
                Description = "Description 3",
                Price = 3.0m
            },
            new Product
            {
                Id = 4,
                Name = "Product 4",
                Sku = "SKU4",
                Description = "Description 4",
                Price = 4.0m
            }
        ];
    }
}

public record Product
{
    public int Id { get; init; }

    public required string Name { get; init; }

    public required string Sku { get; init; }

    public required string Description { get; init; }

    public decimal Price { get; init; }
}