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
    systems.url = "github:nix-systems/default";
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
        import ./libs/pure.nix {
          inherit nixpkgs;
          systems = import systems;
        }
        // forEachSystem (
          system: pkgs:
          import ./libs {
            inherit system pkgs;
          }
        );

      packages = forEachSystem (
        system: pkgs:
        (import ./libs/mkPackages { inherit nixpkgs; }) pkgs (
          pkgs:
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
              shellcheck

              # format
              nixfmt
              prettier

              # util
              nix-update
              gh
              action-validator
              octoscan
              (pkgs.callPackage ./packages/nix-fix-hash { })
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
              (pkgs.callPackage ./packages/nix-fix-hash { })
              (pkgs.callPackage ./packages/renovate { })
            ];
          };

          vulnerable = pkgs.mkShell {
            packages = with pkgs; [
              flake-checker # flake
              octoscan # actions
            ];
          };
        }
      );

      checks = forEachSystem (
        system: pkgs:
        self.libs."${system}".mkChecks {
          actions = {
            root = ./.github/workflows;
            nativeBuildInputs = with pkgs; [
              action-validator
              octoscan
            ];
            forEach = ''
              action-validator "$file"
              octoscan scan "$file" --ignore macos-26
            '';
          };

          renovate = {
            root = ./.github;
            fileset = ./.github/renovate.json;
            deps = [
              (pkgs.callPackage ./packages/renovate { })
            ];
            script = ''
              renovate-config-validator renovate.json
            '';
          };

          nix = {
            root = ./.;
            filter = file: file.hasExt "nix";
            deps = with pkgs; [
              nixfmt
            ];
            forEach = ''
              nixfmt --check "$file"
            '';
          };

          shell = {
            root = ./.;
            filter = file: file.hasExt "sh";
            deps = with pkgs; [
              shellcheck
            ];
            forEach = ''
              shellcheck "$file"
            '';
          };

          prettier = {
            root = ./.;
            filter = file: file.hasExt "yaml" || file.hasExt "json" || file.hasExt "md";
            deps = with pkgs; [
              prettier
            ];
            forEach = ''
              prettier --check "$file"
            '';
          };
        }
        // pkgs.lib.mapAttrs' (
          name: value: pkgs.lib.nameValuePair ("package_" + name) value
        ) self.packages."${system}"
        //
          pkgs.lib.mapAttrs' (name: value: pkgs.lib.nameValuePair ("image_" + name) value)
            self.images."${system}"
      );

      formatter = forEachSystem (system: pkgs: pkgs.nixfmt-tree);
    };
}
