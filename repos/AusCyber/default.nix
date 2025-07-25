# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:
let
  sources = pkgs.callPackage ./_sources/generated.nix { };
in

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
  ghostty = pkgs.callPackage ./pkgs/ghostty {
    source = sources.ghostty;
    sourceRoot = ".";
  };
  ghostty-nightly = pkgs.callPackage ./pkgs/ghostty {
    source = sources.ghostty-nightly;
    sourceRoot = ".";
  };
  zen-browser = pkgs.callPackage ./pkgs/zen-browser {
    source = sources.zen-browser;
    sourceRoot = "Zen.app";
  };
  zen-browser-twilight = pkgs.callPackage ./pkgs/zen-browser {
    source = sources.zen-browser-twilight;
    sourceRoot = "Twilight.app";
  };

  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
