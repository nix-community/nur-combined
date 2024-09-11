
{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  binaryninja = pkgs.callPackage ./pkgs/re/binaryninja { };
  codemerxdecompile = pkgs.callPackage ./pkgs/re/codemerxdecompile { };
  detectiteasy = pkgs.libsForQt5.callPackage ./pkgs/re/detectiteasy { };
  lampray = pkgs.callPackage ./pkgs/gaming/lampray { };
  depotdownloader = pkgs.callPackage ./pkgs/gaming/depotdownloader { };
  elf2uf2-rs = pkgs.callPackage ./pkgs/tooling/elf2uf2-rs { };
  probe-rs-tools = pkgs.callPackage ./pkgs/tooling/probe-rs-tools { };
  mayo = pkgs.libsForQt5.callPackage ./pkgs/mayo { };

  ltsatool = pkgs.callPackage ./pkgs/school/ltsatool { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
