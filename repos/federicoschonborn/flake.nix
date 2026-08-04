{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
        gitignore.follows = "";
      };
    };

    nix-check-deps = {
      url = "github:lordgrimmauld/nix-check-deps";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    # Indirect
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      systems,
      flake-parts,
      git-hooks,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        imports = [
          git-hooks.flakeModule

          ./flake
        ];

        systems = import systems;

        flake.nixosModules = import ./nixos/modules;

        perSystem =
          {
            config,
            pkgs,
            system,
            inputs',
            ...
          }:
          {
            _module.args.pkgs = import nixpkgs {
              inherit system;
              config = {
                # allowAliases = false;
                allowBroken = true;
                allowUnfreePredicate =
                  p:
                  builtins.elem (lib.getName p) [
                    "super-mario-127"
                    "spaghettikart"
                  ];
              };
            };

            legacyPackages = import ./. { inherit system pkgs lib; };
            packages = lib.filterAttrs (_: lib.isDerivation) config.legacyPackages;

            devShells.default = pkgs.mkShellNoCC {
              packages = [
                pkgs.jq
                pkgs.just
                pkgs.nix-init
                pkgs.nix-update
                pkgs.nushell
                inputs'.nix-check-deps.packages.nix-check-deps
              ];

              shellHook = ''
                ${config.pre-commit.installationScript}
              '';
            };

            pre-commit = {
              check.enable = true;
              settings.hooks = {
                # Nix
                nixfmt-rfc-style = {
                  enable = true;
                  package = pkgs.nixfmt-rfc-style;
                };
                deadnix.enable = true;
                statix.enable = true;
              };
            };

            formatter = pkgs.nixfmt-tree;
          };
      }
    );
}
