# FIXME: This is one huge pile of mess that hasn't been maintained since, about, early 2024.

{
  inputs ? import ./lon.nix,
  nixpkgs ? inputs.nixpkgs,
  system ? builtins.currentSystem,
  pkgs ? import nixpkgs { inherit system; }, # Accommodate pkgs passed by NUR
  newScope ? pkgs.newScope,
  lib ? pkgs.lib,
}:

let
  final = pkgs.extend (import ./overlay.nix);
in
final.some-pkgs
// {
  inherit (final) some-pkgs some-datasets some-util;
  inherit (final.some-pkgs) some-pkgs-py;
}
