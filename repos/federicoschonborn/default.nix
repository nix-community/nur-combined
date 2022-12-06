# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  kirigami-addons = pkgs.libsForQt5.callPackage ./packages/kirigami-addons {};

  cargo-aoc = pkgs.callPackage ./packages/cargo-aoc {};
  commit = pkgs.callPackage ./packages/commit {};
  gitklient = pkgs.libsForQt5.callPackage ./packages/gitklient {};
  liquidshell = pkgs.libsForQt5.callPackage ./packages/liquidshell {};
  tokodon = pkgs.libsForQt5.callPackage ./packages/tokodon {inherit kirigami-addons;};
}
