{ pkgs ? import <nixpkgs> {} }:

{
  ueberzug = pkgs.callPackage ./pkgs/ueberzug { };
  nudoku = pkgs.callPackage ./pkgs/nudoku { };
  bemenu = pkgs.callPackage ./pkgs/bemenu { };
  swayblocks = pkgs.callPackage ./pkgs/swayblocks { };
  cboard = pkgs.callPackage ./pkgs/cboard { };
  ripcord = pkgs.callPackage ./pkgs/ripcord { };
  ydotool = pkgs.callPackage ./pkgs/ydotool { };
}

