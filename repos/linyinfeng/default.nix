{ originalPkgs ? import <nixpkgs> { } }:

let
  inherit (originalPkgs) lib;
  overlayList = builtins.attrValues (import ./overlays);
  pkgs = lib.foldl (prev: prev.extend) originalPkgs overlayList;
in
{
  lib = import ./lib { inherit (pkgs) lib; };
  modules = import ./modules;
  overlays = import ./overlays;
}
  //
import ./pkgs { inherit pkgs; }
