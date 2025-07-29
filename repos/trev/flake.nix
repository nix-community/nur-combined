{
  description = "Trev's NUR repository";

  nixConfig = {
    extra-substituters = [
      "https://trevnur.cachix.org"
    ];
    extra-trusted-public-keys = [
      "trevnur.cachix.org-1:hBd15IdszwT52aOxdKs5vNTbq36emvEeGqpb25Bkq6o="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nur = {
      url = "github:nix-community/NUR/835af09a822591ccaa54a889de7d5bc90c8ac968";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nur,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  in rec {
    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [nur.overlays.default];
        };

        update = pkgs.callPackage ./update.nix {};
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            update
            git
            nix-update
            alejandra
            prettier
            action-validator
            pkgs.nur.repos.trev.renovate
          ];
          shellHook = pkgs.nur.repos.trev.shellhook.ref;
        };
      }
    );

    checks = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [nur.overlays.default];
      };
    in
      pkgs.nur.repos.trev.lib.mkChecks {
        lint = {
          src = ./.;
          deps = with pkgs; [
            alejandra
            prettier
            pkgs.nur.repos.trev.renovate
            action-validator
          ];
          script = ''
            alejandra -c .
            prettier --check .
            renovate-config-validator
            action-validator .github/workflows/*
          '';
        };
      }
      // {
        shell = devShells."${system}".default;
      });

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
