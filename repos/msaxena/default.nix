# This file describes the repository contents.
# See https://github.com/nix-community/nur-packages-template

{ pkgs ? import <nixpkgs> { } }:

{
  nixosModules = import ./nixos-modules;

  scrobblex = pkgs.callPackage ./pkgs/scrobblex { };
  trek = pkgs.callPackage ./pkgs/trek { };

  yamtrack = pkgs.callPackage ./pkgs/yamtrack { };
}
