{
  description = "Trev's NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nur = {
      url = "github:nix-community/NUR";
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
            renovate
            action-validator
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
          nativeBuildInputs = with pkgs; [
            alejandra
            prettier
            renovate
            action-validator
          ];
          checkPhase = ''
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
