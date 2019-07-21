{ pkgs ? import <nixpkgs> {} }:

{
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  carla = pkgs.callPackage ./pkgs/carla { };
  cadabra2 = pkgs.callPackage ./pkgs/cadabra2 { };
  worksnaps-client = pkgs.callPackage ./pkgs/worksnaps-client { };
  mathics = pkgs.callPackage ./pkgs/mathics { };
  minimal-sddm-theme = pkgs.callPackage ./pkgs/minimal-sddm-theme { };
  _31key = pkgs.callPackage ./pkgs/31key { };
  mimi = pkgs.callPackage ./pkgs/mimi { };
  quake3-data = pkgs.callPackage ./pkgs/quake3-data { };
}
