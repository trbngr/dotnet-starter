# -----------------------------------------------------------------------------
# INIT
# -----------------------------------------------------------------------------
read -p "Enter the library name: " name

ROOT="${DEVENV_ROOT}/lib"
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
# Create class library project and add any packages the user wants.
# -----------------------------------------------------------------------------
dotnet new classlib --name $project_name --output "src"
dotnet sln $solution_file add $project_file

read -p "Enter any nuget packages to install (space-separated): " -a packages

for pkg in "${packages[@]}"; do
    dotnet add "src/demo.${name}.csproj" package $pkg
done

# -----------------------------------------------------------------------------
# (Optional) Create test project
# -----------------------------------------------------------------------------
dotnet new xunit --name "${test_project_name}" --output "test" --no-restore
dotnet add "${test_project_file}" reference "${project_file}"

# Fix default packagae references to use CPM defined in $DEVENV_ROOT/Directory.Packages.props
packages=(
    coverlet.collector
    Microsoft.NET.Test.Sdk
    xunit
    xunit.runner.visualstudio
)

for pkg in "${packages[@]}"; do
    dotnet remove "${test_project_file}" package "$pkg"
    dotnet add "${test_project_file}" package "$pkg"
done

dotnet add "${test_project_file}" package Moq
dotnet add "${test_project_file}" package JetBrains.Annotations --prerelease

dotnet sln "${solution_file}" add "${test_project_file}"

# -----------------------------------------------------------------------------
# Create slnx file and remove sln file
# -----------------------------------------------------------------------------
dotnet sln "${solution_file}" migrate
rm -f "${solution_file}"

# -----------------------------------------------------------------------------
# Add reference to the common library so all services have access to it.
# -----------------------------------------------------------------------------
dotnet add "${ROOT}/common/src/demo.common.csproj" reference "${project_file}"

# -----------------------------------------------------------------------------
# Expose library to the API solution
# -----------------------------------------------------------------------------
dotnet sln "../../services/api/demo.api.sln" add "../../services/api/src/demo.api.csproj" --solution-folder "lib/${name}" "${project_file}"
dotnet sln "../../services/api/demo.api.sln" add "../../services/api/src/demo.api.csproj" --solution-folder "lib/${name}" "${test_project_file}"
cd -
