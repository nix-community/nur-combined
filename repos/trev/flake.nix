{
  description = "trev's nix user repository (NUR)";

  nixConfig = {
    extra-substituters = [
      "https://cache.trev.zip/nur"
    ];
    extra-trusted-public-keys = [
      "nur:70xGHUW1+1b8FqBchldaunN//pZNVo6FKuPL4U/n844="
    ];
  };

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = {nixpkgs, ...}: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  in rec {
    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
        import ./packages {
          inherit system pkgs;
        }
    );

    bundlers = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
        import ./bundlers {
          inherit system pkgs;
        }
    );

    # the entire attribute set
    legacyPackages = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
        import ./. {
          inherit system pkgs;
        }
    );

    overlays = import ./overlays;

    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        trenovate = pkgs.callPackage ./packages/renovate {};
        update = pkgs.callPackage ./utils/update {};
        shellhook = pkgs.callPackage ./packages/shellhook {};
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            update
            nix-fast-build
            alejandra
            prettier
            action-validator
          ];
          shellHook = shellhook.ref;
        };

        ci = pkgs.mkShell {
          packages = with pkgs; [
            update
            nix-fast-build
            trenovate
            flake-checker
          ];
        };
      }
    );

    checks = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
      libs = import ./libs {
        inherit system pkgs;
      };
      trenovate = pkgs.callPackage ./packages/renovate {};
    in
      libs.mkChecks {
        lint = {
          src = ./.;
          deps = with pkgs; [
            trenovate
            alejandra
            prettier
            action-validator
          ];
          script = ''
            alejandra -c .
            prettier --check .
            action-validator .github/**/*.yaml
            renovate-config-validator .github/renovate.json
          '';
        };
      }
      // packages."${system}");
  };
}
