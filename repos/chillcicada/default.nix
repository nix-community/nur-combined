{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  degit-rs = pkgs.callPackage ./pkgs/degit-rs { };
  tunet-rust = pkgs.callPackage ./pkgs/tunet-rust { };
  typship = pkgs.callPackage ./pkgs/typship { };
}
