{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  compton = pkgs.callPackage ./pkgs/compton { };
  vk-cli = pkgs.callPackage ./pkgs/vk-cli { };
  lyra-cursors = pkgs.callPackage ./pkgs/lyra-cursors { };
  waffle-font = pkgs.callPackage ./pkgs/waffle-font { };
  i3lock-color = pkgs.callPackage ./pkgs/i3lock-color { };
}
