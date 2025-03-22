{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;

{
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  degit-rs = callPackage ./pkgs/degit-rs { };
  tunet-rust = callPackage ./pkgs/tunet-rust { };
  typship = callPackage ./pkgs/typship { };
  wpsoffice-cn = libsForQt5.callPackage ./pkgs/wpsoffice-cn { };
}
