{ pkgs ? import <nixpkgs> {} }:
{
  blackhole-screensaver = pkgs.callPackage ./pkgs/blackhole-screensaver { };
  miniam = pkgs.callPackage ./pkgs/miniam { };
}
