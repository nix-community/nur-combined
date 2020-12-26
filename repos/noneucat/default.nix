{ pkgs ? import <nixpkgs> {} }:

{
  # Add modules paths
  modules = import ./modules;

  # PinePhone-related packages
  pinephone = { 
    sxmo = pkgs.callPackage ./pkgs/pinephone/sxmo/default.nix { };
  };
}
