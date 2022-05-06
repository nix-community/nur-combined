{ pkgs ? import <nixpkgs> { } }:

let
  custom_pkgs = import ./pkgs { inherit pkgs; };

in {
  # The `lib`, `modules`, and `overlay` names are special
  #lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules/nixos; # NixOS modules
  hmModules = import ./modules/home-manager; # Home-manager modules
  #overlays = import ./overlays; # nixpkgs overlays
} // custom_pkgs
