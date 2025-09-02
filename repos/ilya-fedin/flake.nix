{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { nixpkgs, ... }: let
    inherit (nixpkgs) lib;
    forAllSystems = f: lib.genAttrs lib.systems.flakeExposed f;
  in {
    packages = forAllSystems (system:
      lib.filterAttrs
        (name: _: name != "modules" && name != "overlays")
        (import ./. {
          pkgs = import nixpkgs {
            inherit system;
            config = import ./nixpkgs-config.nix;
          };
        })
    );

    nixosModules = import ./modules;

    overlays = import ./overlays;
  };

  nixConfig = {
    substituters = [
      "https://cache.nixos.org/"
      "https://ilya-fedin.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "ilya-fedin.cachix.org-1:QveU24a5ePPMh82mAFSxLk1P+w97pRxqe9rh+MJqlag="
    ];
  };
}
