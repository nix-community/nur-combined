{
  description = "Trev's NUR";

  nixConfig = {
    extra-substituters = [
      "https://cache.trev.zip/nur"
    ];
    extra-trusted-public-keys = [
      "nur:70xGHUW1+1b8FqBchldaunN//pZNVo6FKuPL4U/n844="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  in rec {
    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              renovate = pkgs.callPackage ./pkgs/renovate {};
              nix-update-script = pkgs.callPackage ./pkgs/nix-update-script {
                nix-update = pkgs.callPackage ./pkgs/nix-update {};
              };
            })
          ];
        };
        update = pkgs.callPackage ./update.nix {};
        shellhook = pkgs.callPackage ./pkgs/shellhook {};
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            update
            alejandra
            flake-checker
            prettier
            action-validator
            renovate
          ];
          shellHook = shellhook.ref;
        };
      }
    );

    checks = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        renovate = pkgs.callPackage ./pkgs/renovate {};
      };
      lib = import ./lib {inherit pkgs;};
    in
      lib.mkChecks {
        lint = {
          src = ./.;
          deps = with pkgs; [
            alejandra
            prettier
            action-validator
            renovate
          ];
          script = ''
            alejandra -c .
            prettier --check .
            action-validator .github/**/*.yaml
            renovate-config-validator .github/renovate.json
          '';
        };
      }
      // packages."${system}"
      // {
        shell = devShells."${system}".default;
      });

    overlays.default = import ./overlay.nix;

    legacyPackages = forAllSystems (
      system:
        import ./default.nix {
          inherit system;
          pkgs = nixpkgs.legacyPackages."${system}";
        }
    );

    packages = forAllSystems (
      system:
        nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
    );
  };
}
