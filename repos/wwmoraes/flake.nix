{
  description = "William Artero's nix user repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/25.05?shallow=1";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/treefmt-nix";
    };
    synology-nix-installer.url = "github:sini/synology-nix-installer";

  };

  nixConfig = {
    builders-use-substitutes = true;
    substituters = [
      "https://wwmoraes.cachix.org/"
      "https://nix-community.cachix.org/"
      "https://cache.nixos.org/"
      "https://hercules-ci.cachix.org/"
    ];
    trusted-public-keys = [
      "wwmoraes.cachix.org-1:N38Kgu19R66Jr62aX5rS466waVzT5p/Paq1g6uFFVyM="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hercules-ci.cachix.org-1:ZZeDl9Va+xe9j+KqdzoBZMFJHVQ42Uu/c/1/KMC5Lw0="
    ];
  };

  outputs =
    inputs@{
      flake-parts,
      self,
      systems,
      treefmt-nix,
      ...
    }:
    (flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        darwinModules = import ./modules/darwin;
        homeManagerModules = import ./modules/home-manager;
        nixosModules = import ./modules/nixos;
        treefmtModules = import ./modules/treefmt;
        overlays.default =
          final: prev:
          prev.lib.recursiveUpdate prev {
            nur.repos.wwmoraes = import ./default.nix {
              inherit (prev) system;
              pkgs = prev;
            };
          };
      };

      perSystem =
        {
          lib,
          pkgs,
          self',
          system,
          ...
        }:
        let
          treefmt = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        in
        rec {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              self.overlays.default
              inputs.synology-nix-installer.overlays.default
            ];
            config = { };
          };

          checks = self.packages.${system} // {
            build = pkgs.linkFarmFromDrvs "wwmoraes-nurpkgs" (builtins.attrValues packages);
            formatting = treefmt.config.build.check self;
          };
          devShells = import ./shell.nix { inherit pkgs system; };
          packages =
            let
              packages = lib.filterAttrs (_: v: lib.isDerivation v) self'.legacyPackages;
            in
            {
              default = pkgs.linkFarmFromDrvs "nurpkgs" (builtins.attrValues packages);
            }
            // packages;
          legacyPackages =
            import ./default.nix { inherit pkgs system; }
            // {
              inherit treefmt;
            }
            // lib.optionalAttrs (lib.hasSuffix "-linux" system) {
              inherit (pkgs) nix-installer-static;
            };
          formatter = treefmt.config.build.wrapper;
        };

      systems = import systems;
    });
}
