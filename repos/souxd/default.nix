{ pkgs ? import <nixpkgs> { } }:

{
  beebeep = pkgs.qt5.callPackage ./pkgs/beebeep { };
  glaxnimate = pkgs.qt5.callPackage ./pkgs/glaxnimate { };
}
