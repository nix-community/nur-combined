{ pkgs ? import <nixpkgs> {} }:

with pkgs;

rec {
  modules = import ./modules;

  overlays = import ./overlays;

  exo2 = callPackage ./pkgs/exo2 {};

  gtk-layer-background = callPackage ./pkgs/gtk-layer-background {};

  kotatogram-desktop = libsForQt5.callPackage ./pkgs/kotatogram-desktop {};

  mir = callPackage ./pkgs/mir {};

  mirco = callPackage ./pkgs/mirco {
    inherit mir;
  };

  silver = callPackage ./pkgs/silver {};

  #wlcs = callPackage ./pkgs/wlcs {};
}
