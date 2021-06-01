{ pkgs ? import <nixpkgs> { } }:
let
  args = { inherit pkgs; };
in {
  lib = import ./lib args;
} // (import ./pkgs args)
