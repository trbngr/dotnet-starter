cd "${DEVENV_ROOT}/services/api/src"
read -p "Enter a name for this migration: " name
dotnet ef migrations add $name
cd -