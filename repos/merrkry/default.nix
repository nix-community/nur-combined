{
  pkgs ? import <nixpkgs> { },
}:
{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  delta = pkgs.callPackage ./pkgs/delta.nix { };
  fcitx5-vinput-lite = pkgs.callPackage ./pkgs/fcitx5-vinput-lite { };
  kache = pkgs.callPackage ./pkgs/kache.nix { };
  kvlibadwaita-kvantum = pkgs.callPackage ./pkgs/kvlibadwaita-kvantum.nix { };
}
