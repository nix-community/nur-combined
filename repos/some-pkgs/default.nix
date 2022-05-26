# Use pkgs provided by NUR
{ pkgs ? import <nixpkgs> { } }:

let
  overlay = import ./overlay.nix;
  final = pkgs
    // overlay final pkgs
    // { callPackage = pkgs.lib.callPackageWith final; };
in
final.some-pkgs
