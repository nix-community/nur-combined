{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        inherit (nixpkgs.lib.attrsets) mapAttrs;

        pkgs = import nixpkgs { inherit system; };
        legacyPackages = import ./pkgs { inherit pkgs; };
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        nixosModules = mapAttrs (name: path: import path) (import ./modules);
        inherit legacyPackages;
        packages = flake-utils.lib.flattenTree legacyPackages;
      });
}
