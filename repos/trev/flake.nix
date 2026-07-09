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
    schema.url = "github:DeterminateSystems/flake-schemas";
    systems.url = "github:spotdemo4/systems";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      schema,
      systems,
      nixpkgs,
      self,
    }:
    let
      systemPkgs = nixpkgs.lib.genAttrs (import systems) (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );

      forEachSystem =
        function: nixpkgs.lib.genAttrs (import systems) (system: function system systemPkgs.${system});
    in
    {
      overlays = import ./overlays {
        inherit nixpkgs;
      };

      nixosModules = import ./modules {
        inherit nixpkgs;
      };

      schemas =
        schema.schemas
        // import ./schemas {
          inherit (nixpkgs) lib;
        };

      libs =
        forEachSystem (
          system: pkgs:
          import ./libs {
            inherit system pkgs;
          }
        )
        // {
          mkFlake = import ./libs/mkFlake {
            inherit nixpkgs;
            systems = import systems;
            schemas = schema.schemas // import ./schemas { inherit nixpkgs; };
          };
        };

      packages = forEachSystem (
        system: pkgs:
        pkgs.lib.filterAttrs (_: package: pkgs.lib.meta.availableOn { inherit system; } package) (
          import ./packages {
            inherit system pkgs;
          }
        )
      );

      bundlers = forEachSystem (
        system: pkgs:
        import ./bundlers {
          inherit system pkgs;
        }
      );

      images = forEachSystem (
        system: pkgs:
        import ./images {
          inherit system pkgs;
        }
      );

      legacyPackages = forEachSystem (
        system: pkgs:
        import ./. {
          inherit nixpkgs system pkgs;
        }
      );

      devShells = forEachSystem (
        system: pkgs: {
          default = pkgs.mkShell {
            shellHook = (pkgs.callPackage ./packages/shellhook { }).ref;
            packages = with pkgs; [
              # lint
              nil
              nixd
              shellcheck

              # format
              nixfmt
              oxfmt
              treefmt

              # util
              nix-init
              nix-update
              gh
              action-validator
              octoscan
              (pkgs.callPackage ./packages/fix-hash { })
              (pkgs.callPackage ./packages/fetch-hash { })
            ];
          };

          check = pkgs.mkShell {
            packages = with pkgs; [
              nix-fast-build
            ];
          };

          update = pkgs.mkShell {
            packages = with pkgs; [
              nix-update
              (pkgs.callPackage ./packages/fix-hash { })
              (pkgs.callPackage ./packages/renovate { })
            ];
          };

          vulnerable = pkgs.mkShell {
            packages = with pkgs; [
              flake-checker # flake
              zizmor # actions
            ];
          };
        }
      );

      checks = forEachSystem (
        system: pkgs:
        self.libs."${system}".mkChecks {
          actions = {
            root = ./.github/workflows;
            packages = with pkgs; [
              action-validator
              zizmor
            ];
            script = ''
              action-validator "$file"
              zizmor --offline "$file"
            '';
          };

          renovate = {
            root = ./.github;
            files = ./.github/renovate.json;
            packages = [
              (pkgs.callPackage ./packages/renovate { })
            ];
            script = ''
              renovate-config-validator renovate.json
            '';
          };

          nix = {
            root = ./.;
            filter = file: file.hasExt "nix";
            packages = with pkgs; [
              nixfmt
            ];
            script = ''
              nixfmt --check "$file"
            '';
          };

          shell = {
            root = ./.;
            filter = file: file.hasExt "sh";
            packages = with pkgs; [
              shellcheck
            ];
            script = ''
              shellcheck "$file"
            '';
          };

          conf = {
            root = ./.;
            filter = file: file.hasExt "json" || file.hasExt "yaml" || file.hasExt "toml" || file.hasExt "md";
            packages = with pkgs; [
              oxfmt
            ];
            script = ''
              oxfmt --check
            '';
          };
        }
        // import ./packages/duckdb/checks.nix { inherit (pkgs) lib callPackage; }
        // pkgs.lib.mapAttrs' (
          name: value: pkgs.lib.nameValuePair ("package_" + name) value
        ) self.packages."${system}"
        //
          pkgs.lib.mapAttrs' (name: value: pkgs.lib.nameValuePair ("image_" + name) value)
            self.images."${system}"
      );

      formatter = forEachSystem (
        system: pkgs:
        pkgs.treefmt.withConfig {
          configFile = ./treefmt.toml;
          runtimeInputs = with pkgs; [
            nixfmt
            oxfmt
          ];
        }
      );
    };
}
