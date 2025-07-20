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
    allow-import-from-derivation = false;

    substituters = [
      "https://fym998-nur.cachix.org"
      "https://pre-commit-hooks.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];

    trusted-public-keys = [
      "fym998-nur.cachix.org-1:lWwztkEXGJsiJHh/5FbA2u95AxJu8/k4udgGqdFLhOU="
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        lib,
        ...
      }:
      {
        imports = [
          ./flake-modules/_internal/dev.nix
          ./flake-modules/_internal/ci.nix
        ];
        flake.overlays = import ./overlays;
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
            ciPackages = lib.filterAttrs (name: _p: !lib.hasPrefix "_" name) self'.packages;
          }
          // import ./pkgs { inherit pkgs; };
      }
    );
}
