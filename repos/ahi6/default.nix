{ pkgs ? import <nixpkgs> { } }:

rec {
  flake8_json = pkgs.python3Packages.callPackage ./pkgs/flake8_json { };
  edulint = pkgs.python3Packages.callPackage ./pkgs/edulint { inherit flake8_json; };
}
