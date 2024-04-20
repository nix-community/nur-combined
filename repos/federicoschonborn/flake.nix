{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    systems.url = "github:nix-systems/default";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs-stable";
        flake-utils.follows = "flake-utils";
        gitignore.follows = "gitignore";
        flake-compat.follows = "";
      };
    };

    # Indirect
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      systems,
      flake-parts,
      pre-commit-hooks,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import systems;

      perSystem =
        {
          lib,
          config,
          pkgs,
          system,
          ...
        }:
        {
          legacyPackages = pkgs.callPackage ./packages { };
          packages = lib.filterAttrs (_: lib.isDerivation) config.legacyPackages;

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              jq
              just
              nix-inspect
              nix-output-monitor
              nix-tree
            ];

            shellHook = ''
              ${config.checks.pre-commit-check.shellHook}
              just --list
            '';
          };

          apps.update = {
            type = "app";
            program = lib.getExe (
              pkgs.writeShellApplication {
                name = "update";
                text = ''
                  nix-shell --show-trace "${nixpkgs.outPath}/maintainers/scripts/update.nix" \
                    --arg include-overlays "[(import ./overlay.nix)]" \
                    --arg predicate '(
                      let prefix = builtins.toPath ./packages; prefixLen = builtins.stringLength prefix;
                      in (_: p: p.meta?position && (builtins.substring 0 prefixLen p.meta.position) == prefix)
                    )'
                '';
              }
            );
          };

          checks = {
            pre-commit-check = pre-commit-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                # Nix
                nixfmt = {
                  enable = true;
                  package = config.formatter;
                };
                deadnix.enable = true;
                statix.enable = true;
              };
            };
          };

          formatter = pkgs.nixfmt-rfc-style;
        };
    };

  nixConfig = {
    extra-substituters = [ "https://federicoschonborn.cachix.org" ];
    extra-trusted-public-keys = [
      "federicoschonborn.cachix.org-1:tqctt7S1zZuwKcakzMxeATNq+dhmh2v6cq+oBf4hgIU="
    ];
  };
}
