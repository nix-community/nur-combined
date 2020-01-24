{ pkgs ? import <nixpkgs> { }, enablePkgsCompat ? true }:

let libExtension = import ./lib; self = {
  lib = libExtension pkgs.lib { };
  inherit libExtension;
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # Nixpkgs overlays
  pkgs = import ./pkgs { inherit pkgs; inherit libExtension; };
}; in if enablePkgsCompat then self.pkgs // self else self
