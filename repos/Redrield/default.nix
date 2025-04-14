
{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  atlauncher = pkgs.callPackage ./pkgs/gaming/atlauncher-bin { };
  binaryninja = pkgs.callPackage ./pkgs/re/binaryninja { };
  codemerxdecompile = pkgs.callPackage ./pkgs/re/codemerxdecompile { };
  detectiteasy = pkgs.libsForQt5.callPackage ./pkgs/re/detectiteasy { };
  depotdownloader = pkgs.callPackage ./pkgs/gaming/depotdownloader { };
  mayo = pkgs.libsForQt5.callPackage ./pkgs/mayo { };

  flog-symbols-ttf = pkgs.callPackage ./pkgs/fonts/flog-symbols.nix { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
