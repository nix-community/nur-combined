{ pkgs ? import <nixpkgs> { } }:

let
  nurPkgs = import ./pkgs (pkgs // nurPkgs) pkgs;
in
{
  # The `modules`, and `overlay` names are special
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
} // nurPkgs # nixpkgs packages
