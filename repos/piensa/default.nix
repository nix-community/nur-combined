{ pkgs ? import <nixpkgs> {} }:
      
rec {
  tegola = pkgs.callPackage ./pkgs/tegola { };

  modules = import ./modules;
} 
