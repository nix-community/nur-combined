{ pkgs ? import <nixpkgs> {} }:

with pkgs;

rec {
  modules = import ./modules;

  kotatogram-desktop = qt5.callPackage ./pkgs/kotatogram-desktop {
    inherit libtgvoip;
  };

  libtgvoip = callPackage ./pkgs/libtgvoip {};

  silver = callPackage ./pkgs/silver {};
}
