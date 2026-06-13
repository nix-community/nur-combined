{
  pkgs ? import <nixpkgs> { },
}:
{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  deeplx = pkgs.callPackage ./pkgs/deeplx.nix { };

  jackify-bin = pkgs.callPackage ./pkgs/jackify-bin.nix { };

  kvlibadwaita-kvantum = pkgs.callPackage ./pkgs/kvlibadwaita-kvantum.nix { };

  # Vendored from https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/t3/t3code/package.nix.
  # `OverrideAttrs` with `symlinkJoin` is ideal, but this package doesn't allow us to override the hash of `nodeModules` FOD.
  t3code = pkgs.callPackage ./pkgs/t3code.nix { };
}
