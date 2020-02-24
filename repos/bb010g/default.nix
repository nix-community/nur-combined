{ pkgs ? import <nixpkgs> { }, enablePkgsCompat ? true }:

let self = {
  lib = self.lib'.standalone pkgs.lib;
  lib' = import ./lib;
  libExtension = self.lib'.extension;
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # Nixpkgs overlays
  pkgs = import ./pkgs { inherit pkgs; inherit (self) libExtension; };
}; in if enablePkgsCompat then self.pkgs // self else self
