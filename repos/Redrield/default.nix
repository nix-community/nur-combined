
{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  binaryninja = pkgs.callPackage ./pkgs/binaryninja { };
  codemerxdecompile = pkgs.callPackage ./pkgs/codemerxdecompile { };
  detectiteasy = pkgs.libsForQt5.callPackage ./pkgs/detectiteasy { };
  lampray = pkgs.callPackage ./pkgs/lampray { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
