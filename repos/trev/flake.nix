{
  description = "trev's nix repository";

  nixConfig = {
    extra-substituters = [
      "https://cache.trev.zip/nur"
    ];
    extra-trusted-public-keys = [
      "nur:70xGHUW1+1b8FqBchldaunN//pZNVo6FKuPL4U/n844="
    ];
  };

  inputs = {
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { systems, nixpkgs, ... }:
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
      in
      rec {
        packages = import ./packages {
          inherit system pkgs;
        };

        bundlers = import ./bundlers {
          inherit system pkgs;
        };

        # the entire attribute set
        legacyPackages = import ./. {
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

        overlays = import ./overlays;

        devShells = {
          default = pkgs.mkShell {
            packages =
              let
                update = pkgs.callPackage ./utils/update { };
              in
              [
                update
                pkgs.nixfmt
                pkgs.prettier
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
                trenovate = pkgs.callPackage ./packages/renovate { };
                update = pkgs.callPackage ./utils/update { };
              in
              [
                update
                trenovate
              ];
          };

          vulnerable = pkgs.mkShell {
            packages = with pkgs; [
              flake-checker
            ];
          };
        };

        checks =
          libs."${system}".mkChecks {
            lint = {
              src = ./.;
              deps =
                let
                  trenovate = pkgs.callPackage ./packages/renovate { };
                in
                [
                  pkgs.nixfmt-tree
                  pkgs.prettier
                  pkgs.action-validator
                  trenovate
                ];
              script = ''
                treefmt --ci
                prettier --check .
                action-validator .github/**/*.yaml
                renovate-config-validator .github/renovate.json
              '';
            };
          }
          // packages;

        formatter = pkgs.nixfmt-tree;
      }
    );
}
