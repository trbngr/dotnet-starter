using C4Sharp.Diagrams.Builders;
using C4Sharp.Elements;
using C4Sharp.Elements.Relationships;

namespace demo.architecture.Diagrams;

using static Dsl;

public class SequenceDiagramSample : SequenceDiagram
{
    protected override string Title => "Sequence diagram for Internet Banking System";

    protected override IEnumerable<Structure> Structures =>
    [
        CreateContainer("cA")
            .WithLabel("Single-Page-Application")
            .WithType(ContainerType.None)
            .UsingTechnology("JavaScript and Angular")
            .DescribedAs("Provides all of the Internet banking functionality to customers via their web browser."),

        Bound(
            alias: "b",
            label: "Api Application",
            structures:
            [
                CreateComponent("cB")
                    .WithLabel("Sign In Controller")
                    .OfType(ComponentType.None)
                    .UsingTechnology("Spring MVC Rest Controller")
                    .DescribedAs("Allows users to sign in to the Internet Banking System."),

                CreateComponent("cC")
                    .WithLabel("Security Component")
                    .OfType(ComponentType.None)
                    .UsingTechnology("Spring Bean")
                    .DescribedAs("Provides functionality Related to signing in, changing passwords, etc.")
            ]
        ),

        CreateContainer("cD")
            .WithLabel("Database")
            .WithType(ContainerType.Database)
            .UsingTechnology("Relational Database Schema")
            .DescribedAs("Stores user registration information, hashed authentication credentials, access logs, etc.")
    ];

    protected override IEnumerable<Relationship> Relationships =>
    [
        It(key: "cA") > It(key: "cB") | ("Submits credentials to", "JSON/HTTPS"),
        It(key: "cB") > It(key: "cC") | "Calls isAuthenticated() on",
        It(key: "cC") > It(key: "cD") | ("select * from users where username = ?o", "JDBCS")
    ];
}