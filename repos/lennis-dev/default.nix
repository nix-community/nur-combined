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

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  dev-lennis-www = pkgs.callPackage ./pkgs/dev-lennis-www { };
  email-obfuscater = pkgs.callPackage ./pkgs/email-obfuscater { };
  hackit = pkgs.callPackage ./pkgs/hackit { };
  update-my-nur = pkgs.callPackage ./pkgs/update-my-nur { };
  xauth-server = pkgs.callPackage ./pkgs/xauth-server { };
  gio-project-avatar-fetcher = pkgs.callPackage ./pkgs/gio-project-avatar-fetcher { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
