{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  compton = pkgs.callPackage ./pkgs/compton { };
  lyra-cursors = pkgs.callPackage ./pkgs/lyra-cursors { };
  bitmap-fonts = pkgs.callPackage ./pkgs/bitmap-fonts { };
  i3lock-color = pkgs.callPackage ./pkgs/i3lock-color { };
  sddm-chili = pkgs.callPackage ./pkgs/sddm-chili { };
}
