{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-24_05.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        flake-parts-lib,
        lib,
        config,
        ...
      }:
      let
        inherit (flake-parts-lib) importApply;
        flakeModules = {
          auto-apps-shell = ./flake-modules/auto-apps-shell.nix;
          auto-colmena-hive = ./flake-modules/auto-colmena-hive-v0.nix;
          auto-colmena-hive-v0 = ./flake-modules/auto-colmena-hive-v0.nix;
          auto-colmena-hive-v0_20241006 = ./flake-modules/auto-colmena-hive-v0_20241006.nix;
          commands = ./flake-modules/commands.nix;
          lantian-pre-commit-hooks = importApply ./flake-modules/lantian-pre-commit-hooks.nix {
            inherit (inputs) pre-commit-hooks-nix;
          };
          lantian-treefmt = importApply ./flake-modules/lantian-treefmt.nix { inherit (inputs) treefmt-nix; };
          nixpkgs-options = ./flake-modules/nixpkgs-options.nix;
        };

        pkgsForSystem-24_05 =
          system:
          import inputs.nixpkgs-24_05 {
            inherit system;
            config = {
              inherit (config.nixpkgs-options) allowUnfree;
              inherit (config.nixpkgs-options) permittedInsecurePackages;
            };
          };
      in
      rec {
        imports = [
          ./flake-modules/_internal/ci-outputs.nix
          ./flake-modules/_internal/commands.nix
          ./flake-modules/_internal/meta.nix
          ./flake-modules/_internal/modules-test-nixos-config.nix
          flakeModules.commands
          flakeModules.lantian-pre-commit-hooks
          flakeModules.lantian-treefmt
          flakeModules.nixpkgs-options
        ];

        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        flake = {
          overlay = self.overlays.default;
          overlays =
            {
              default =
                final: prev:
                let
                  _packages = import ./pkgs null {
                    pkgs = prev;
                    pkgs-24_05 = pkgsForSystem-24_05 final.system;
                    inherit inputs;
                  };
                  _legacyPackages = import ./pkgs "legacy" {
                    pkgs = prev;
                    pkgs-24_05 = pkgsForSystem-24_05 final.system;
                    inherit inputs;
                  };
                in
                _packages
                // rec {
                  # Integrate to nixpkgs python3Packages
                  python = prev.python.override {
                    packageOverrides = _final: _prev: _legacyPackages.python3Packages;
                  };
                  python3 = prev.python3.override {
                    packageOverrides = _final: _prev: _legacyPackages.python3Packages;
                  };
                  python3Packages = python3.pkgs;
                };
              inSubTree = final: prev: {
                nur-xddxdd = import ./pkgs null {
                  pkgs = prev;
                  pkgs-24_05 = pkgsForSystem-24_05 final.system;
                  inherit inputs;
                };
              };
              inSubTree-pinnedNixpkgs = final: _prev: {
                nur-xddxdd = self.legacyPackages.${final.system};
              };
              inSubTree-pinnedNixpkgsWithCuda = final: _prev: {
                nur-xddxdd = self.legacyPackagesWithCuda.${final.system};
              };
            }
            // (builtins.listToAttrs (
              lib.flatten (
                builtins.map (s: [
                  {
                    name = "pinnedNixpkgs-${s}";
                    value = _final: _prev: self.legacyPackages.${s};
                  }
                  {
                    name = "pinnedNixpkgsWithCuda-${s}";
                    value = _final: _prev: self.legacyPackagesWithCuda.${s};
                  }
                ]) systems
              )
            ));

          inherit flakeModules;

          nixosModules = {
            setupOverlay = _: { nixpkgs.overlays = [ self.overlays.default ]; };
            kata-containers = import ./modules/kata-containers.nix;
            lyrica = import ./modules/lyrica.nix;
            nix-cache-attic = import ./modules/nix-cache-attic.nix;
            nix-cache-cachix = import ./modules/nix-cache-cachix.nix;
            nix-cache-garnix = import ./modules/nix-cache-garnix.nix;
            openssl-oqs-provider = import ./modules/openssl-oqs-provider.nix;
            qemu-user-static-binfmt = import ./modules/qemu-user-static-binfmt.nix;
            wireguard-remove-lingering-links = import ./modules/wireguard-remove-lingering-links.nix;
          };
        };

        nixpkgs-options = {
          pkgs = {
            sourceInput = inputs.nixpkgs;
            allowInsecurePredicate = _: true;
          };
          pkgsWithCuda = {
            sourceInput = inputs.nixpkgs;
            allowInsecurePredicate = _: true;
            settings.enableCuda = true;
          };
        };

        perSystem =
          {
            pkgs,
            pkgsWithCuda,
            system,
            ...
          }:
          {
            packages = import ./pkgs null {
              inherit inputs pkgs;
              pkgs-24_05 = pkgsForSystem-24_05 system;
            };
            packagesWithCuda = import ./pkgs null {
              inherit inputs;
              pkgs = pkgsWithCuda;
              pkgs-24_05 = pkgsForSystem-24_05 system;
            };
            legacyPackages = import ./pkgs "legacy" {
              inherit inputs pkgs;
              pkgs-24_05 = pkgsForSystem-24_05 system;
            };
            legacyPackagesWithCuda = import ./pkgs "legacy" {
              inherit inputs;
              pkgs = pkgsWithCuda;
              pkgs-24_05 = pkgsForSystem-24_05 system;
            };
          };
      }
    );
}
