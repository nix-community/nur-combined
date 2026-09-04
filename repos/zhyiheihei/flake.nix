{
  description = "zhyiheihei's NUR repository";

  inputs = {
    # Pin to the last revision where our pnpm-based packages still build
    # (pnpm_9 was removed by later nixpkgs updates). Auto-update keeps
    # refreshing package sources while nixpkgs itself stays stable.
    nixpkgs.url = "github:NixOS/nixpkgs/f13ff45afd1bb73e640eaa08a7066dbed07e3238";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # keep-sorted start block=yes
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixfmt-rs = {
      url = "github:Mic92/nixfmt-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # keep-sorted end
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
          commands = importApply ./flake-modules/commands.nix {
            inherit (inputs) devshell;
            inherit flake-parts-lib;
          };
          lantian-pre-commit-hooks = importApply ./flake-modules/lantian-pre-commit-hooks.nix {
            inherit (inputs) pre-commit-hooks-nix;
          };
          lantian-treefmt = importApply ./flake-modules/lantian-treefmt.nix {
            inherit (inputs) treefmt-nix nixfmt-rs;
          };
          nixpkgs-options = ./flake-modules/nixpkgs-options.nix;
        };
      in
      rec {
        imports = [
          # keep-sorted start
          ./flake-modules/_internal/ci-outputs.nix
          ./flake-modules/_internal/commands.nix
          ./flake-modules/_internal/meta.nix
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
              in
              _packages;
            inSubTree = final: prev: {
              nur-zhyiheihei = import ./pkgs null {
                pkgs = prev;
                inherit inputs;
              };
            };
          };

          inherit flakeModules;

          nixosModules = {
            setupOverlay = _: { nixpkgs.overlays = [ self.overlays.default ]; };

            # ZCode 桌面应用（包在 pkgs/uncategorized/zcode）。上层仓库只
            # import 本模块并设 lantian.zcode.enable，不再重复逻辑。
            zcode = import ./nixos-modules/zcode.nix { inherit self; };
          };

          hydraJobs.packages.x86_64-linux = self.hydraPackages.x86_64-linux;
        };

        perSystem =
          {
            pkgs,
            pkgsWithCuda,
            ...
          }:
          rec {
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

            legacyPackages = import ./pkgs "legacy" {
              inherit inputs pkgs;
            };
            legacyPackagesWithCuda = import ./pkgs "legacy" {
              inherit inputs;
              pkgs = pkgsWithCuda;
            };

            packages = lib.filterAttrs (_: lib.isDerivation) legacyPackages;
            packagesWithCuda = lib.filterAttrs (_: lib.isDerivation) legacyPackagesWithCuda;

            devshells.default = {
              packages = [
                pkgs.python3
                pkgs.nix-update
              ];
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
