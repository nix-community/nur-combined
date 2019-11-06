{ pkgs ? import <nixpkgs> { }, enablePkgsCompat ? true }:

let self = {
  lib = import ./lib { inherit pkgs; inherit (pkgs) lib; };
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # Nixpkgs overlays
  pkgs = import ./pkgs { inherit pkgs; selfLib = import ./lib; };
}; in if enablePkgsCompat then self.pkgs // self else self
