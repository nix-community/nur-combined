{ pkgs ? import <nixpkgs> {} }:

{
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  carla = pkgs.callPackage ./pkgs/carla { };
  helio-workstation = pkgs.callPackage ./pkgs/helio-workstation { };
  kvirc = pkgs.callPackage ./pkgs/kvirc { };
  cadabra2 = pkgs.callPackage ./pkgs/cadabra2 { };
  worksnaps-client = pkgs.callPackage ./pkgs/worksnaps-client { };
  mathics = pkgs.callPackage ./pkgs/mathics { };
  minimal-sddm-theme = pkgs.callPackage ./pkgs/minimal-sddm-theme { };
}
