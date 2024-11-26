# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: let
  yuzuPackages = pkgs.callPackage ./pkgs/yuzu {};
in {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  jetbrains-resharper-cli = pkgs.callPackage ./pkgs/jetbrains-resharper-cli {};
  nudelta = pkgs.callPackage ./pkgs/nudelta {};
  fw-fanctrl = pkgs.callPackage ./pkgs/fw-fanctrl {};
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
  # yuzu-ea = yuzuPackages.early-access; # Added 2022-08-18
  # yuzu-early-access = yuzuPackages.early-access; # Added 2023-12-29
  # yuzu = yuzuPackages.mainline; # Added 2021-01-25
  # yuzu-mainline = yuzuPackages.mainline; # Added 2023-12-29

  gitignore = pkgs.callPackage ./pkgs/gitignore {};
  dotnet-t4 = pkgs.callPackage ./pkgs/dotnet-t4 {};
  bigquery-emulator = pkgs.callPackage ./pkgs/bigquery-emulator {};
}
