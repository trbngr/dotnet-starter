using C4Sharp.Elements;

namespace demo.architecture.Structures;

using static Dsl;

public static class Components
{
    public static Component Sign => CreateComponent("sign")
        .WithLabel("Sign In Controller")
        .UsingTechnology("MVC Controller")
        .DescribedAs("Allows users to sign in to the internet banking system");

    public static Component Accounts => CreateComponent("accounts")
        .WithLabel("Accounts Summary Controller")
        .UsingTechnology("MVC Controller")
        .DescribedAs("Provides customers with a summary of their bank accounts");

    public static Component Security => CreateComponent("security")
        .WithLabel("Security Component")
        .UsingTechnology("Spring Bean")
        .DescribedAs("Provides functionality related to singing in, changing passwords, etc.");

    public static Component MainframeFacade => CreateComponent("mbsfacade")
        .WithLabel("Mainframe Banking System Facade")
        .UsingTechnology("Spring Bean")
        .DescribedAs("A facade onto the mainframe banking system.");

}