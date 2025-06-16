using C4Sharp.Diagrams;
using C4Sharp.Diagrams.Builders;
using C4Sharp.Elements;
using C4Sharp.Elements.Relationships;
using static demo.architecture.Structures.Systems;
using static demo.architecture.Structures.Containers;
using static demo.architecture.Structures.Components;

namespace demo.architecture.Diagrams;

public class ComponentDiagramSample : ComponentDiagram
{
    protected override string Title => "Internet Banking System API Application";
    protected override DiagramLayout FlowVisualization => DiagramLayout.LeftRight;

    protected override IEnumerable<Structure> Structures =>
    [
        MobileApp,
        SqlDatabase,
        Mainframe,
        Bound("c1", "API Application",
            Sign,
            Accounts,
            Security,
            MainframeFacade
        )
    ];

    protected override IEnumerable<Relationship> Relationships =>
    [
        Sign > Security,
        Accounts > MainframeFacade,
        Security > SqlDatabase | ("Read & write to", "JDBC"),
        MainframeFacade > Mainframe | ("Uses", "XML/HTTPS"),

        SpaApp > Sign | ("Uses", "JSON/HTTPS"),
        SpaApp > Accounts | ("Uses", "JSON/HTTPS"),
        MobileApp > Sign | ("Uses", "JSON/HTTPS"),
        MobileApp > Accounts | ("Uses", "JSON/HTTPS")
    ];
}