{
  description = "Hawtian's NUR repository";

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }
  : let
    filterDerivations = attrs: (
      nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) attrs
    );
    filterNotDerivations = attrs: (
      nixpkgs.lib.filterAttrs (_: v: !(nixpkgs.lib.isDerivation v) && builtins.isAttrs v) attrs
    );
    filterOutEmptyAttrs = attrs: (
      nixpkgs.lib.filterAttrs (_: v: v != null && v != {}) attrs
    );
    recurseFilterDerivations = attrs: let
      directDerivations = filterDerivations attrs;
      notDerivations = filterNotDerivations attrs;
      recurseResult = nixpkgs.lib.mapAttrs (_: value: recurseFilterDerivations value) notDerivations;
    in
      directDerivations // (filterOutEmptyAttrs recurseResult);
  in
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in rec {
        legacyPackages = import ./default.nix {
          inherit pkgs;
        };
        directDerivations = filterDerivations legacyPackages;
        notDerivations = filterNotDerivations legacyPackages;
        packages = recurseFilterDerivations legacyPackages;
      }
    );

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
}
