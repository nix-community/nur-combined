{ pkgs ? import <nixpkgs> {} }:
let
  importSet = path: import path {
    inherit pkgs;
    inherit (pkgs) lib;
    callPackage = pkgs.lib.callPackageWith (pkgs // packages);
  };

  packages = importSet ./pkgs;

  top-level = {
    lib = importSet ./lib;
    modules = import ./modules {
      inherit pkgs;
      inherit (pkgs) lib;
    };
  };
in packages // top-level
