{ pkgs ? import <nixpkgs> {} }:
let
  lib = import ./lib;
in
{

  inherit lib;

  modules = import ./modules;

  overlays = import ./overlays;

  pkgs = import ./pkgs { inherit lib pkgs; };

}
