{
  pkgs ? import <nixpkgs> { },
}:
{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  deeplx = pkgs.callPackage ./pkgs/deeplx.nix { };
  fcitx5-commit-string-dbus = pkgs.callPackage ./pkgs/fcitx5-commit-string-dbus/package.nix { };
  jackify-bin = pkgs.callPackage ./pkgs/jackify-bin.nix { };
  kvlibadwaita-kvantum = pkgs.callPackage ./pkgs/kvlibadwaita-kvantum.nix { };
}
