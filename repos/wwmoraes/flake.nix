{
  description = "William Artero's nix user repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable?shallow=1";
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
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org/"
      "https://wwmoraes.cachix.org/"
      "https://hercules-ci.cachix.org/"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "wwmoraes.cachix.org-1:N38Kgu19R66Jr62aX5rS466waVzT5p/Paq1g6uFFVyM="
      "hercules-ci.cachix.org-1:ZZeDl9Va+xe9j+KqdzoBZMFJHVQ42Uu/c/1/KMC5Lw0="
    ];
  };

  outputs =
    inputs@{
      self,
      ...
    }:
    (inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      flake = {
        overlays = (import ./overlays) // {
          default =
            final: prev:
            prev.lib.recursiveUpdate prev {
              nur.repos.wwmoraes = import ./default.nix {
                inherit (prev) system;
                pkgs = prev;
              };
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
          drvPackages = lib.filterAttrs (_: v: lib.isDerivation v) self'.legacyPackages;
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              self.overlays.default
              inputs.synology-nix-installer.overlays.default
            ];
            config = { };
          };

          checks = drvPackages;
          devShells = import ./shell.nix { inherit pkgs system; };
          # explicitly skip modules as they break nix flake check; in fact the
          # upstream NUR suggestion is an abuse of the packages attribute. They
          # are still accessible through legacyPackages.
          #
          # Instead the default.nix provides manually set modules attributes
          # which are compatible with the NUR paths. The advantage to that is
          # I can have extra, unsupported module class groups as well, such as
          # treefmt modules.
          #
          # See https://github.com/nix-community/NUR/blob/main/README.md#user-content-nixos-modules-overlays-and-library-function-support
          packages = drvPackages // {
            default = pkgs.linkFarmFromDrvs "nurpkgs" (builtins.attrValues drvPackages);
          };

          legacyPackages =
            import ./default.nix { inherit pkgs system; }
            // lib.optionalAttrs (lib.hasSuffix "-linux" system) {
              inherit (pkgs) nix-installer-static;
            };
        };

      systems = import inputs.systems;
    });
}
