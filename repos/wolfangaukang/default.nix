{ pkgs ? import <nixpkgs> { } }:

let
  custom_pkgs = import ./pkgs/top-level/all-packages.nix { inherit pkgs; };

in {
  # The `lib`, `modules`, and `overlay` names are special
  #lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./system/modules; # NixOS modules
  hmModules = import ./home/modules; # Home-manager modules
  #overlays = import ./overlays; # nixpkgs overlays
} // custom_pkgs
