{ pkgs ? import <nixpkgs> { } }:

let
  inherit (pkgs) lib;
  overlayList = builtins.attrValues (import ./overlays);
  pkgs' = lib.foldl (prev: prev.extend) pkgs overlayList;
  selfLib = import ./lib { inherit (pkgs') lib; };
in
{
  lib = selfLib;
  modules = import ./modules;
  overlays = import ./overlays;
}
  //
lib.attrsets.removeAttrs
  (pkgs'.callPackage ./pkgs {
    inherit selfLib;
  }) [
  "devPackages"
]
