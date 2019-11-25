{ pkgs ? import <nixpkgs> {} }:

{
  ueberzug = pkgs.callPackage ./pkgs/ueberzug { };
  nudoku = pkgs.callPackage ./pkgs/nudoku { };
  bemenu = pkgs.callPackage ./pkgs/bemenu { };
  cboard = pkgs.callPackage ./pkgs/cboard { };
  ripcord = pkgs.callPackage ./pkgs/ripcord { };
  deezloader-remix = pkgs.callPackage ./pkgs/deezloader-remix { };
}

