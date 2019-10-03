{ pkgs ? import <nixpkgs> {} }:

let
  listDirectory = import lib/listDirectory.nix;
  pathDirectory = listDirectory (x: x);
  importDirectory = listDirectory import;
  callDirectory = listDirectory (p: pkgs.callPackage p {});

  pkgs' = callDirectory ./pkgs;
in pkgs' // {
  pkgs = pkgs';
  lib = importDirectory ./lib;
  modules = pathDirectory ./modules;
}
