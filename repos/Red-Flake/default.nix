# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

# automatically call packages under pkgs/
builtins.mapAttrs (name: _: 
  if name == "bloodhound-ce-py" 
  then import (./pkgs + "/${name}") { inherit pkgs; }  # call directly to use default python
  else pkgs.callPackage (./pkgs + "/${name}") {}
) (builtins.readDir ./pkgs)
// {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # automatic packages can still be overriden
}
