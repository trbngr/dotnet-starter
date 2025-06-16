#!/usr/bin/env bash

set -e

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------
to_pascal_case() {
    local input="$1"
    local output=""
    IFS='-_ ' read -ra parts <<<"$input"
    for part in "${parts[@]}"; do
        output+="${part^}"
    done
    echo "$output"
}

set_hotchocolate_module_name() {
    local name=$(to_pascal_case $1)
    cat >src/Properties/ModuleInfo.cs <<EOF
// ReSharper disable CheckNamespace
[assembly: HotChocolate.Module("${name}Module")]
namespace demo;
public static class ${name}Module
{
    public static void Add${name}Module(this Wolverine.WolverineOptions options) =>
        options.Discovery.IncludeAssembly(typeof(${name}Module).Assembly);
}
EOF
}

create_hotchocolate_queries() {
    local name=$1
    local pname=$(to_pascal_case $1)
    cat >src/Types/${pname}Queries.cs <<EOF
using HotChocolate.Language;
using HotChocolate.Types;

namespace demo.${name}.Types;

[ExtendObjectType(OperationType.Query)]
public class ${pname}Queries
{
}
EOF
}

create_hotchocolate_mutations() {
    local name=$1
    local pname=$(to_pascal_case $1)
    cat >src/Types/${pname}Mutations.cs <<EOF
using HotChocolate.Language;
using HotChocolate.Types;

namespace demo.${name}.Types;

[ExtendObjectType(OperationType.Mutation)]
public class ${pname}Mutations
{
}
EOF
}

add_hotchocolate_module() {
    local pname=$(to_pascal_case "$1")
    local api_program_file="${DEVENV_ROOT}/services/api/src/Program.cs"
    local tmp_file="${api_program_file}.tmp"

    awk -v mod="\t.Add${pname}Module()" '
        /\.AddTypes\(\)/ {
            print mod
        }
        { print }
    ' "$api_program_file" >"$tmp_file" && mv "$tmp_file" "$api_program_file"
}

export_module_to_wolverine() {
    local pname=$(to_pascal_case "$1")
    local api_program_file="${DEVENV_ROOT}/services/api/src/Program.cs"
    local tmp_file="${api_program_file}.tmp"

    # Avoid duplicate insertion
    if grep -q "opts.Add${pname}Module();" "$api_program_file"; then
        echo "Already added: opts.Add${pname}Module();"
        return
    fi

    awk -v insert="\topts.Add${pname}Module();" '
        /opts\.Policies\.AutoApplyTransactions\(\);/ {
            print
            print insert
            next
        }
        { print }
    ' "$api_program_file" > "$tmp_file" && mv "$tmp_file" "$api_program_file"
}


configure_hotchocolate() {
    mkdir src/Types
    set_hotchocolate_module_name $1
    create_hotchocolate_mutations $1
    create_hotchocolate_queries $1
    add_hotchocolate_module $1
}

# this repo uses central package management, so we have to remove the packages
# installed with the dotnet template and re-add them
reset_test_packages() {
    local test_project_file=$1
    local packages=(
        coverlet.collector
        Microsoft.NET.Test.Sdk
        xunit
        xunit.runner.visualstudio
    )
    for pkg in "${packages[@]}"; do
        dotnet remove "$test_project_file" package "$pkg" || true
    done
    for pkg in "${packages[@]}"; do
        dotnet add "$test_project_file" package "$pkg"
    done
    dotnet add "$test_project_file" package Moq
    dotnet add "$test_project_file" package JetBrains.Annotations --prerelease
}

create_test_project() {
    local test_project_file=$1
    local project_file=$2
    local solution_file=$3

    dotnet new xunit --name "$(basename "$test_project_file" .csproj)" --output "$(dirname "$test_project_file")" --no-restore
    reset_test_packages "$test_project_file"
    dotnet add "$test_project_file" reference "$project_file"
    dotnet sln "$solution_file" add "$test_project_file"
}

finalize_solution() {
    dotnet sln "$1" migrate
    rm -f "$1"
}

main() {
    echo "Choose the project type:"
    select TYPE in "console" "library" "service"; do
        if [[ -n "$TYPE" ]]; then
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done

    read -p "Enter the project name: " name

    case "$TYPE" in
    console)
        ROOT="${DEVENV_ROOT}/internal/tools"
        TEMPLATE="console"
        ;;
    library)
        ROOT="${DEVENV_ROOT}/lib"
        TEMPLATE="classlib"
        ;;
    service)
        ROOT="${DEVENV_ROOT}/services"
        TEMPLATE="web"
        ;;
    *)
        echo "Unknown type: $TYPE"
        exit 1
        ;;
    esac

    read -p "Enter any nuget packages to install (space-separated): " -a packages

    solution_name="demo.${name}"
    solution_file="${solution_name}.sln"
    project_name="demo.${name}"
    project_file="src/${project_name}.csproj"
    test_project_name="demo.${name}.tests"
    test_project_file="test/${test_project_name}.csproj"

    mkdir -p "${ROOT}/${name}"
    cd "${ROOT}/${name}"

    dotnet new sln --name "$solution_name"
    dotnet new "$TEMPLATE" --name "$project_name" --output "src"
    dotnet sln "$solution_file" add "$project_file"

    for pkg in "${packages[@]}"; do
        dotnet add "$1" package "$pkg"
    done

    create_test_project "$test_project_file" "$project_file" "$solution_file"
    finalize_solution "$solution_file"

    # -----------------------------------------------------------------------------
    # TYPE-SPECIFIC BEHAVIOR
    # -----------------------------------------------------------------------------
    if [[ "$TYPE" == "library" ]]; then
        dotnet add "${ROOT}/common/src/demo.common.csproj" reference "$project_file"
        dotnet sln "${DEVENV_ROOT}/services/api/demo.api.slnx" add \
            "${project_file}" "${test_project_file}" \
            --solution-folder "lib/${name}"

    elif [[ "$TYPE" == "service" ]]; then
        configure_hotchocolate $name
        export_module_to_wolverine  $name
        dotnet add "$project_file" reference "${DEVENV_ROOT}/lib/common/src/demo.common.csproj"
        dotnet sln "${solution_file}x" add "$project_file" --solution-folder lib/common "${DEVENV_ROOT}/lib/common/src/demo.common.csproj"

        dotnet add "${DEVENV_ROOT}/services/api/src/demo.api.csproj" reference "$project_file"
        dotnet sln "${DEVENV_ROOT}/services/api/demo.api.slnx" add \
            "../api/src/demo.api.csproj" \
            --solution-folder "modules/${name}" "$project_file" "$test_project_file"

        cd "${DEVENV_ROOT}/frontend"
        nx g @nx/react:library --directory="libraries/${name}" --bundler=vite --name="${name}" --unitTestRunner=vitest
        nx g @nx/react:storybook-configuration --project="${name}" --configureStaticServe=true --generateStories=true --interactionTests=true
        cd -
    fi

    cd -
}

main "$@"
