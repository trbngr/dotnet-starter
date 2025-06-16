{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  pkgs-upstream = import inputs.nixpkgs-upstream { system = pkgs.stdenv.system; };
  internal = "$DEVENV_ROOT/internal";
in
{
  packages = [
    pkgs.git
    pkgs.jetbrains.rider
  ];

  languages = {
    dotnet = {
      enable = true;
      package = (
        pkgs.dotnetCorePackages.combinePackages [
          # optional sdks
          # pkgs.dotnet-sdk_10
          pkgs.dotnet-sdk_9
        ]
      );
    };

    typescript.enable = true;

    javascript = {
      enable = true;
      package = pkgs-upstream.nodejs_24;
      pnpm = {
        enable = true;
        install.enable = true;
      };
    };
  };

  services = {
    rabbitmq = {
      enable = true;
    };

    keycloak = {
      enable = true;
      realms.deepstaging = {
        path = "./etc/keycloak/deepstaging.json";
        import = true;
        export = true;
      };
    };

    postgres = {
      enable = true;
      port = 5435;
      listen_addresses = "127.0.0.1";
      initialScript = "CREATE ROLE postgres SUPERUSER;";
      initialDatabases = [
        {
          name = "demo";
          user = "postgres";
          pass = "postgres";
        }
      ];
    };
  };

  scripts = {
    code-api.exec = "rider $DEVENV_ROOT/services/api/demo.api.slnx";
    code-architecture.exec = "rider ${internal}/tools/architecture/demo.architecture.slnx";
    code-frontend.exec = "code $DEVENV_ROOT/frontend";

    create-migration.exec = "${internal}/scripts/create-migration.sh";
    create-project.exec = "${internal}/scripts/create-project.sh";
    
    generate-c4.exec = "dotnet run --project ${internal}/tools/architecture/src/demo.architecture.csproj";
    
    run-migrations.exec = "${internal}/scripts/run-migrations.sh";
    
    up.exec = "devenv processes up";
  };

  enterShell = ''
    echo "------------"
    git --version
    echo "dotnet version $(dotnet --version)"
    echo "pnpm version $(pnpm --version)"
    echo "node version $(node --version)"
    echo "typescript $(tsc --version)"
    echo ""
    echo "------------"
    dotnet tool restore --tool-manifest "$DEVENV_ROOT/.config/dotnet-tools.json"
    echo "------------"
    echo "Demo Shell"
  '';

  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  devcontainer.enable = true;
}
