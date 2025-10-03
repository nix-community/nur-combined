{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-parts.url = "github:hercules-ci/flake-parts";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
        ...
      }:
      let
        inherit (flake-parts-lib) importApply;
        flakeModules = {
          auto-apps-shell = ./flake-modules/auto-apps-shell.nix;
          auto-colmena-hive = ./flake-modules/auto-colmena-hive-v0.nix;
          auto-colmena-hive-v0 = ./flake-modules/auto-colmena-hive-v0.nix;
          auto-colmena-hive-v0_20241006 = ./flake-modules/auto-colmena-hive-v0_20241006.nix;
          auto-colmena-hive-v0_5 = ./flake-modules/auto-colmena-hive-v0_5.nix;
          commands = importApply ./flake-modules/commands.nix {
            inherit (inputs) devshell;
            inherit flake-parts-lib;
          };
          lantian-pre-commit-hooks = importApply ./flake-modules/lantian-pre-commit-hooks.nix {
            inherit (inputs) pre-commit-hooks-nix;
          };
          lantian-treefmt = importApply ./flake-modules/lantian-treefmt.nix { inherit (inputs) treefmt-nix; };
          nixpkgs-options = ./flake-modules/nixpkgs-options.nix;
        };
      in
      rec {
        imports = [
          # keep-sorted start
          ./flake-modules/_internal/ci-outputs.nix
          ./flake-modules/_internal/commands.nix
          ./flake-modules/_internal/meta.nix
          ./flake-modules/_internal/modules-test-nixos-config.nix
          flakeModules.commands
          flakeModules.lantian-pre-commit-hooks
          flakeModules.lantian-treefmt
          flakeModules.nixpkgs-options
          # keep-sorted end
        ];

        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        flake = {
          overlay = self.overlays.default;
          overlays = {
            default =
              final: prev:
              let
                _packages = import ./pkgs null {
                  pkgs = prev;
                  inherit inputs;
                };
                _legacyPackages = import ./pkgs "legacy" {
                  pkgs = prev;
                  inherit inputs;
                };
              in
              _packages
              // rec {
                # Integrate to nixpkgs python3Packages
                python = prev.python.override {
                  packageOverrides = final: prev: _legacyPackages.python3Packages;
                };
                python3 = prev.python3.override {
                  packageOverrides = final: prev: _legacyPackages.python3Packages;
                };
                python3Packages = python3.pkgs;
              };
            inSubTree = final: prev: {
              nur-xddxdd = import ./pkgs null {
                pkgs = prev;
                inherit inputs;
              };
            };
            inSubTree-pinnedNixpkgs = final: prev: {
              nur-xddxdd = self.legacyPackages.${final.system};
            };
            inSubTree-pinnedNixpkgsWithCuda = final: prev: {
              nur-xddxdd = self.legacyPackagesWithCuda.${final.system};
            };
          }
          // (builtins.listToAttrs (
            lib.flatten (
              builtins.map (s: [
                {
                  name = "pinnedNixpkgs-${s}";
                  value = final: prev: self.legacyPackages.${s};
                }
                {
                  name = "pinnedNixpkgsWithCuda-${s}";
                  value = final: prev: self.legacyPackagesWithCuda.${s};
                }
              ]) systems
            )
          ));

          inherit flakeModules;

          nixosModules = {
            # keep-sorted start
            kata-containers = import ./modules/kata-containers.nix;
            lyrica = import ./modules/lyrica.nix;
            nix-cache-attic = import ./modules/nix-cache-attic.nix;
            nix-cache-cachix = import ./modules/nix-cache-cachix.nix;
            nix-cache-garnix = import ./modules/nix-cache-garnix.nix;
            openssl-conf = import ./modules/openssl-conf.nix;
            openssl-gost-engine = import ./modules/openssl-gost-engine.nix;
            openssl-oqs-provider = import ./modules/openssl-oqs-provider.nix;
            qemu-user-static-binfmt = import ./modules/qemu-user-static-binfmt.nix;
            setupOverlay = _: { nixpkgs.overlays = [ self.overlays.default ]; };
            wireguard-remove-lingering-links = import ./modules/wireguard-remove-lingering-links.nix;
            # keep-sorted end
          };
        };

        perSystem =
          {
            pkgs,
            pkgsWithCuda,
            ...
          }:
          {
            nixpkgs-options = {
              pkgs = {
                sourceInput = inputs.nixpkgs;
                allowInsecurePredicate = _: true;
              };
              pkgsWithCuda = {
                sourceInput = inputs.nixpkgs;
                allowInsecurePredicate = _: true;
                settings.cudaSupport = true;
              };
            };

            packages = import ./pkgs null {
              inherit inputs pkgs;
            };
            packagesWithCuda = import ./pkgs null {
              inherit inputs;
              pkgs = pkgsWithCuda;
            };
            legacyPackages = import ./pkgs "legacy" {
              inherit inputs pkgs;
            };
            legacyPackagesWithCuda = import ./pkgs "legacy" {
              inherit inputs;
              pkgs = pkgsWithCuda;
            };

            devshells.default = {
              packages = [ pkgs.python3 ];
              env = [
                {
                  name = "PYTHONPATH";
                  unset = true;
                }
              ];
            };
          };
      }
    );
}
