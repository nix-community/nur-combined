{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default-linux";
  };

  nixConfig = {
    extra-substituters = [
      "https://pre-commit-hooks.cachix.org"
      "https://fym998-nur.cachix.org"
    ];

    extra-trusted-public-keys = [
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      "fym998-nur.cachix.org-1:lWwztkEXGJsiJHh/5FbA2u95AxJu8/k4udgGqdFLhOU="
    ];
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        lib,
        withSystem,
        moduleWithSystem,
        ...
      }:
      {
        imports = [
          ./dev/flake-module.nix
        ];
        flake = {
          overlays = import ./overlays;
        };
        systems = import inputs.systems;
        perSystem =
          {
            self',
            pkgs,
            system,
            ...
          }:
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
                allowUnsupportedSystem = true;
              };
            };

            # for nix-fast-build
            checks =
              lib.mapAttrs' (name: value: lib.nameValuePair "package-${name}" value)
                (import ./ci.nix {
                  inherit pkgs;
                  nurPkgs = self'.packages;
                  currentSystem = system;
                }).cachePackages;
          }
          // import ./pkgs.nix { inherit pkgs; };
      }
    );
}
