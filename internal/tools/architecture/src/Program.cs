// See https://aka.ms/new-console-template for more information

using C4Sharp.Diagrams;
using C4Sharp.Diagrams.Plantuml;
using C4Sharp.Diagrams.Themes;
using demo.architecture.Diagrams;

var diagrams = new DiagramBuilder[]
{
    new ContextDiagramSample(),
    new ComponentDiagramSample(),
    new ContainerDiagramSample(),
    new EnterpriseDiagramSample(),
    new SequenceDiagramSample(),
    new DeploymentDiagramSample()
};

var repoRoot = string.Concat(Enumerable.Repeat("../", 6));

new PlantumlContext()
    .UseDiagramSvgImageBuilder()
    .Export(
        diagrams: diagrams,
        theme: new ParadisoTheme(),
        path: Path.Combine(repoRoot, "docs/architecture")
    );