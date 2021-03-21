{ pkgs ? import <nixpkgs> {} }:

with pkgs;

rec {
  modules = import ./modules;

  exo2 = callPackage ./pkgs/exo2 {};

  kotatogram-desktop = qt5.callPackage ./pkgs/kotatogram-desktop {
    inherit libtgvoip;
  };

  libtgvoip = callPackage ./pkgs/libtgvoip {};

  silver = callPackage ./pkgs/silver {};
}
