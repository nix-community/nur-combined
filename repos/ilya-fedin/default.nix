{ pkgs ? import <nixpkgs> {} }:

with pkgs;

rec {
  modules = import ./modules;

  overlays = import ./overlays;

  exo2 = callPackage ./pkgs/exo2 {};

  kotatogram-desktop = qt5.callPackage ./pkgs/kotatogram-desktop {};

  silver = callPackage ./pkgs/silver {};
}
