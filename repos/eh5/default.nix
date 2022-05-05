{ pkgs ? import <nixpkgs> { } }:
let
  myPkgs = import ./packages;
in
{
  lib.utils = import ./utils;
  modules = import ./modules;
  overlays = myPkgs.overlays;
  overlay = myPkgs.overlays.default;
} // (myPkgs.nurPackages pkgs)
