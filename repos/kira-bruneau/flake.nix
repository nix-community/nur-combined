{
  description = "My personal NUR repository";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          config.allowUnfree = true;
          inherit system;
        };

        nurPkgs = import ./pkgs (pkgs // nurPkgs) pkgs;
      in
      rec {
        checks = packages;
        packages = flake-utils.lib.filterPackages system (flake-utils.lib.flattenTree nurPkgs);
        apps = {
          sync = {
            type = "app";
            program = toString (nurPkgs.callPackage ./maintainers/scripts/sync.nix {
              rev = nixpkgs.rev;
            });
          };
        };
      }
    ) // rec {
      overlays = import ./overlays;
      nixosModules = nixpkgs.lib.mapAttrs (name: value: import value) (import ./nixos/modules);
    };
}
