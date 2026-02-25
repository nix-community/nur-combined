{
  description = "trev's nix repository";

  nixConfig = {
    extra-substituters = [
      "https://nix.trev.zip"
    ];
    extra-trusted-public-keys = [
      "trev:I39N/EsnHkvfmsbx8RUW+ia5dOzojTQNCTzKYij1chU="
    ];
  };

  inputs = {
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      systems,
      nixpkgs,
      ...
    }:
    let
      mkFlake = import ./libs/mkFlake {
        systems = import systems;
      };
    in
    mkFlake (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        fs = pkgs.lib.fileset;
      in
      rec {
        packages = pkgs.lib.filterAttrs (_: pkg: builtins.elem system pkg.meta.platforms) (
          import ./packages {
            inherit system pkgs;
          }
        );

        # the entire attribute set
        legacyPackages = import ./. {
          inherit system pkgs;
        };

        bundlers = import ./bundlers {
          inherit system pkgs;
        };

        libs =
          # pure libs without pkgs/system injected
          import ./libs/pure.nix {
            systems = import systems;
          }
          # libs for each system
          // pkgs.lib.genAttrs (import systems) (
            system:
            import ./libs {
              inherit system pkgs;
            }
          );

        images = import ./images {
          inherit system pkgs;
        };

        overlays = import ./overlays;

        nixosModules = import ./modules;

        devShells = {
          default = pkgs.mkShell {
            packages =
              let
                nix-fix-hash = pkgs.callPackage ./packages/nix-fix-hash { };
                fetch-hash = pkgs.callPackage ./packages/fetch-hash { };
              in
              with pkgs;
              [
                nix-fix-hash
                fetch-hash
                nixfmt
                prettier
                nix-update
                gh
              ];
            shellHook =
              let
                shellhook = pkgs.callPackage ./packages/shellhook { };
              in
              shellhook.ref;
          };

          check = pkgs.mkShell {
            packages = with pkgs; [
              nix-fast-build
            ];
          };

          update = pkgs.mkShell {
            packages =
              let
                nix-fix-hash = pkgs.callPackage ./packages/nix-fix-hash { };
                trenovate = pkgs.callPackage ./packages/renovate { };
              in
              with pkgs;
              [
                nix-fix-hash
                trenovate
                nix-update
              ];
          };

          vulnerable = pkgs.mkShell {
            packages = with pkgs; [
              # flake
              flake-checker

              # actions
              octoscan
            ];
          };
        };

        checks =
          libs."${system}".mkChecks {
            actions = {
              src = fs.toSource {
                root = ./.;
                fileset = ./.github/workflows;
              };
              deps = with pkgs; [
                action-validator
                octoscan
              ];
              script = ''
                action-validator **/*.yaml
                octoscan scan .
              '';
            };

            renovate = {
              src = fs.toSource {
                root = ./.github;
                fileset = ./.github/renovate.json;
              };
              deps =
                let
                  trenovate = pkgs.callPackage ./packages/renovate { };
                in
                [
                  trenovate
                ];
              script = ''
                renovate-config-validator renovate.json
              '';
            };

            nix = {
              src = fs.toSource {
                root = ./.;
                fileset = fs.fileFilter (file: file.hasExt "nix") ./.;
              };
              deps = with pkgs; [
                nixfmt-tree
              ];
              script = ''
                treefmt --ci
              '';
            };

            prettier = {
              src = fs.toSource {
                root = ./.;
                fileset = fs.fileFilter (file: file.hasExt "yaml" || file.hasExt "json" || file.hasExt "md") ./.;
              };
              deps = with pkgs; [
                prettier
              ];
              script = ''
                prettier --check .
              '';
            };
          }
          // packages
          // images;

        formatter = pkgs.nixfmt-tree;
      }
    );
}
