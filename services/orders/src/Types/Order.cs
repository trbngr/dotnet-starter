namespace demo.orders.Types;

public class Order
{
    public int Id { get; set; }

    public required string Name { get; set; }

    public required string Description { get; set; }

    public List<LineItem> Items { get; set; } = [];
}