{
  description = "My personal NUR repository";

  inputs =  {
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
      in
      rec {
        legacyPackages = import ./pkgs {
          inherit pkgs;
        };
      }
    ) // rec {
      overlay = overlays.nur;
      overlays = import ./overlays;
      nixosModules = nixpkgs.lib.mapAttrs (name: value: import value) (import ./modules);
    };
}
