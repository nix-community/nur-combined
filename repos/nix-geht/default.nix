{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> {inherit system;},
}: let
  mypkgs = pkgs.callPackage ./pkgs {};
in
  {
    lib = import ./lib {inherit pkgs;}; # functions
    modules = import ./modules; # NixOS modules
    pkgs = mypkgs; # custom packages.
  }
  // mypkgs
