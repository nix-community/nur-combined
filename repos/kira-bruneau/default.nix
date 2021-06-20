{ pkgs ? import <nixpkgs> { } }:

{
  # The `modules`, and `overlay` names are special
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
} // import ./pkgs { inherit pkgs; } # nixpkgs packages
