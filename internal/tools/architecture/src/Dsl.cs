using C4Sharp.Elements;

namespace demo.architecture;

public static class Dsl
{
    public static ContainerDsl CreateContainer(string alias) => new(alias, "", ContainerType.None, "", "");
    public static ComponentDsl CreateComponent(string alias) => new(alias, "", ComponentType.None, "", "");

    public record ContainerDsl(string Alias, string Label, ContainerType Type, string Technology, string Description)
    {
        public ContainerDsl WithLabel(string label) => this with { Label = label };
        public ContainerDsl WithType(ContainerType type) => this with { Type = type };
        public ContainerDsl UsingTechnology(string technology) => this with { Technology = technology };
        public ContainerDsl DescribedAs(string description) => this with { Description = description };

        public static implicit operator Container(ContainerDsl dsl) =>
            new(dsl.Alias, dsl.Label, dsl.Type, dsl.Technology, dsl.Description);
    }

    public record ComponentDsl(string Alias, string Label, ComponentType ComponentType, string Technology, string Description)
    {
        public ComponentDsl WithLabel(string label) => this with { Label = label };
        public ComponentDsl OfType(ComponentType type) => this with { ComponentType = type };
        public ComponentDsl UsingTechnology(string technology) => this with { Technology = technology };
        public ComponentDsl DescribedAs(string description) => this with { Description = description };

        public static implicit operator Component(ComponentDsl dsl) =>
            new(dsl.Alias, dsl.Label, dsl.ComponentType, dsl.Technology, dsl.Description);
    }
}
