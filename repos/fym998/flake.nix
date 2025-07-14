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
          inputs.flake-parts.flakeModules.easyOverlay
        ];
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
            overlayAttrs = self'.legacyPackages;
            ciPackages = lib.filterAttrs (name: _p: !lib.hasPrefix "_" name) self'.packages;
          }
          // import ./pkgs { inherit pkgs; };
      }
    );
}
