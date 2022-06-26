{ pkgs ? import <nixpkgs> { } }:

let
  inherit (pkgs) lib;
  overlayList = builtins.attrValues (import ./overlays);
  pkgs' = lib.foldl (prev: prev.extend) pkgs overlayList;
in
{
  lib = import ./lib { inherit (pkgs') lib; };
  modules = import ./modules;
  overlays = import ./overlays;
}
  //
pkgs'.callPackage ./pkgs { }
