# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
  
  maintainers = import ./maintainers.nix;

  # example-package = pkgs.callPackage ./pkgs/example-package { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
  
  lix-game = pkgs.callPackage ./pkgs/lix-game { inherit lix-game-assets lix-game-music maintainers; };
  lix-game-assets = pkgs.callPackage ./pkgs/lix-game/assets.nix { inherit lix-game; };
  lix-game-music = pkgs.callPackage ./pkgs/lix-game/music.nix { inherit lix-game; };
  lix-game-server = pkgs.callPackage ./pkgs/lix-game/server.nix { inherit lix-game; };
  
  xscorch = pkgs.callPackage ./pkgs/xscorch { inherit maintainers; };
}
