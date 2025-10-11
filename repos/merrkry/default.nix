{
  pkgs ? import <nixpkgs> { },
}:
{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  deeplx = pkgs.callPackage ./pkgs/deeplx.nix { };
  jackify = pkgs.callPackage ./pkgs/jackify.nix { };
  kvlibadwaita-kvantum = pkgs.callPackage ./pkgs/kvlibadwaita-kvantum.nix { };
}
