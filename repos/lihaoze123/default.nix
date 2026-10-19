{ pkgs ? import <nixpkgs> { } }:
(import ./lib/package-set.nix { inherit pkgs; }) // {
  lib = import ./lib { inherit pkgs; };
  nixosModules = import ./nixos-modules;
  overlays = import ./overlays;
}
