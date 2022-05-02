{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> {
  inherit system;
  overlays = (import ./overlays.nix);
} }:

let
  packages = {
    autorestic = pkgs.callPackage ./pkgs/autorestic { };
    activitywatch-bin = pkgs.callPackage ./pkgs/activitywatch-bin { };
    datalad = pkgs.callPackage ./pkgs/datalad { };
    warpd = pkgs.callPackage ./pkgs/warpd { };
  };
  supportedSystem = (name: pkg: builtins.elem system pkg.meta.platforms);
in (pkgs.lib.filterAttrs supportedSystem packages)
