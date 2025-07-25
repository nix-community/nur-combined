{ pkgs ? import <nixpkgs> {} }:
pkgs.callPackage ./package.nix {
  electron_36 = pkgs.electron_36;
}