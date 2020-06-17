{ pkgs ? import <nixpkgs> { }, ... }:

{
  # pkgs
  nixify = pkgs.callPackage ./pkgs/nixify { };
  nix-search = pkgs.callPackage ./pkgs/nix-search { };

  # modules
  modules = import ./modules;
}
