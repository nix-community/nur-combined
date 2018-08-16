{ pkgs ? import <nixpkgs> {} }:

{
  overlays.full = import ./default.nix;
  pkgs = import ./default.nix pkgs pkgs;
} // (import ./default.nix pkgs pkgs)

