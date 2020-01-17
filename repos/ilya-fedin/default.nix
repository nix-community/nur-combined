{ pkgs ? import <nixpkgs> {} }:

with pkgs;

rec {
  modules = import ./modules;

  kotatogram-desktop = qt5.callPackage ./pkgs/kotatogram-desktop {
    inherit libtgvoip rlottie-tdesktop;
  };

  libtgvoip = callPackage ./pkgs/libtgvoip {};

  rlottie-tdesktop = callPackage ./pkgs/rlottie-tdesktop {};

  silver = callPackage ./pkgs/silver {};
}
