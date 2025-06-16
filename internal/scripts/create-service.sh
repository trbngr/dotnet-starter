# -----------------------------------------------------------------------------
# INIT
# -----------------------------------------------------------------------------
read -p "Enter the service name: " name

ROOT="${DEVENV_ROOT}/services"
solution_name="demo.${name}"
solution_file="demo.${name}.sln"
project_name="demo.${name}"
project_file="src/${project_name}.csproj"
test_project_name="demo.${name}.tests"
test_project_file="test/${test_project_name}.csproj"

cd "${ROOT}/${name}"

# -----------------------------------------------------------------------------
# Create solution file
# -----------------------------------------------------------------------------
dotnet new sln --name "${solution_name}"

# -----------------------------------------------------------------------------
# Create web project and add any packages the user wants.
# -----------------------------------------------------------------------------
dotnet new web --name $project_name --output "src"
dotnet sln $solution_file add $project_file
dotnet sln $solution_file add $project_file --solution-folder lib/common "${DEVENV_ROOT}/lib/common/src/demo.common.csproj"
dotnet add $project_file reference "${DEVENV_ROOT}/lib/common/src/demo.common.csproj"

read -p "Enter any nuget packages to install (space-separated): " -a packages

for pkg in "${packages[@]}"; do
    dotnet add $project_file package $pkg
done

# -----------------------------------------------------------------------------
# (Optional) Create test project
# -----------------------------------------------------------------------------
dotnet new xunit --name $test_project_name --output "test" --no-restore
dotnet add $test_project_file reference $project_file

# Fix default packagae references to use CPM defined in $DEVENV_ROOT/Directory.Packages.props
packages=(
    coverlet.collector
    Microsoft.NET.Test.Sdk
    xunit
    xunit.runner.visualstudio
)

for pkg in "${packages[@]}"; do
    dotnet remove $test_project_file package $pkg
    dotnet add $test_project_file package $pkg
done

dotnet add $test_project_file package Moq
dotnet add $test_project_file package JetBrains.Annotations --prerelease

dotnet sln $solution_file add $test_project_file

# -----------------------------------------------------------------------------
# Create slnx file and remove sln file
# -----------------------------------------------------------------------------
dotnet sln $solution_file migrate
rm -f $solution_file


# -----------------------------------------------------------------------------
# Add reference to api project
# -----------------------------------------------------------------------------
dotnet add "${DEVENV_ROOT}/services/api/src/demo.api.csproj" reference "src/demo.${name}.csproj"
dotnet sln "${DEVENV_ROOT}/services/api/demo.api.sln" add "../api/src/demo.api.csproj" --solution-folder "modules/${name}" "src/demo.${name}.csproj"
dotnet sln "${DEVENV_ROOT}/services/api/demo.api.sln" add "../api/src/demo.api.csproj" --solution-folder "modules/${name}" "test/demo.${name}.tests.csproj"

# -------------------
# Create React Library
# ---------
cd -
cd "${DEVENV_ROOT}/frontend"

# Create React Lib
nx g @nx/react:library --directory="libraries/${name}" --bundler=vite --name="${name}" --unitTestRunner=vitest
nx g @nx/react:storybook-configuration --project="${name}" --configureStaticServe=true --generateStories=true --interactionTests=true

cd -