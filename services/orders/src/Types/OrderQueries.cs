using HotChocolate.Language;
using HotChocolate.Types;

namespace demo.orders.Types;

[ExtendObjectType(OperationType.Query)]
public class OrderQueries
{
    public static Order[] GetOrders() =>
    [
        new()
        {
            Id = 1,
            Name = "Order 1",
            Description = "Description 1",
            Items =
            [
                new() { Id = 1, Quantity = 1, ProductId = 1 },
                new() { Id = 2, Quantity = 2, ProductId = 2 }
            ]
        },
        new()
        {
            Id = 2,
            Name = "Order 2",
            Description = "Description 2",
            Items =
            [
                new() { Id = 3, Quantity = 3, ProductId = 3 },
                new() { Id = 4, Quantity = 4, ProductId = 4 }
            ]
        }
    ];
}