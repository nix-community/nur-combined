{ pkgs ? import <nixpkgs> { } }:
let
  legacy = import ./pkgs/top-level/all-packages.nix { inherit pkgs; };
in
legacy //
{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;
}
