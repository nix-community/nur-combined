{ pkgs ? import <nixpkgs> { } }:
  pkgs.haskellPackages.callPackage ./project.nix { }
