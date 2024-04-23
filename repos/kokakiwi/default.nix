{ pkgs ? import <nixpkgs> {}
}: let
  packages = import ./pkgs {
    inherit pkgs;
    inherit (pkgs) callPackage;
  };
in packages
