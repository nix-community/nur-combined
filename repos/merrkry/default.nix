{
  pkgs ? import <nixpkgs> { },
}:
{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  fcitx5-vinput-lite = pkgs.callPackage ./pkgs/fcitx5-vinput-lite { };
  kvlibadwaita-kvantum = pkgs.callPackage ./pkgs/kvlibadwaita-kvantum.nix { };
}
