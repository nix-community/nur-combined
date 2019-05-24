{ pkgs ? import <nixpkgs> {} }:
let
  pkgs_ = pkgs;
  mypkgs = import ./pkgs { pkgs = pkgs_; };
in
{
  lib = import ./lib { pkgs = pkgs_; };
  modules = import ./modules;
  overlays = import ./overlays;
  pkgs = mypkgs;
} // mypkgs
