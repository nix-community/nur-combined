{ pkgs ? import <nixpkgs> {} }:
      
rec {
  tegola = pkgs.callPackage ./pkgs/tegola { };
  hydra = pkgs.callPackage ./pkgs/hydra { };
  keto = pkgs.callPackage ./pkgs/keto { };
  oathkeeper = pkgs.callPackage ./pkgs/oathkeeper { };
  packr = pkgs.callPackage ./pkgs/packr { };
  blender = pkgs.callPackage ./pkgs/blender { };
  kepler = pkgs.callPackage ./pkgs/kepler { };
  colombia = pkgs.callPackage ./pkgs/colombia { };

  modules = import ./modules;
} 
