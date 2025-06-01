{
  pkgs ? import <nixpkgs> { },
}:

{
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  ark-pixel-font = pkgs.callPackage ./pkgs/ark-pixel-font { };
  fusion-pixel-font = pkgs.callPackage ./pkgs/fusion-pixel-font { };
}
// pkgs.lib.packagesFromDirectoryRecursive {
  callPackage = pkgs.callPackage;
  directory = ./pkgs/by-name;
}
