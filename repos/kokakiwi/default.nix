{ pkgs ? import <nixpkgs> {}
}: let
  inherit (pkgs) lib;

  packages = import ./pkgs {
    inherit pkgs;
    callPackage = lib.callPackageWith (pkgs // packages);
  };
in packages
