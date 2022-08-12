{ pkgs ? import <nixpkgs> { } }:
let
  myPkgs = import ./packages;
in
{
  modules = import ./modules;
  overlays = myPkgs.overlays;
  overlay = myPkgs.overlays.default;
} // (myPkgs.legacyPackages pkgs)
