{ pkgs ? import <nixpkgs> {} }:
      
rec {
  tegola = pkgs.callPackage ./pkgs/tegola { };
  hydra = pkgs.callPackage ./pkgs/hydra { };

  modules = import ./modules;
} 
