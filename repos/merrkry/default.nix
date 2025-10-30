{
  pkgs ? import <nixpkgs> { },
}:
{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  deeplx = pkgs.callPackage ./pkgs/deeplx.nix { };
  handy-bin = pkgs.callPackage ./pkgs/handy-bin.nix { };
  jackify-bin = pkgs.callPackage ./pkgs/jackify-bin.nix { };
  kvlibadwaita-kvantum = pkgs.callPackage ./pkgs/kvlibadwaita-kvantum.nix { };
}
