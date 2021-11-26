# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  your-editor = pkgs.callPackage ./pkgs/your-editor { };
  i3-swallow = pkgs.callPackage ./pkgs/i3-swallow { };
  zig-master = pkgs.callPackage ./pkgs/zig-master { };
  nyxt-dev = pkgs.callPackage ./pkgs/nyxt-dev { };
  runescape-launcher = pkgs.callPackage ./pkgs/runescape-launcher/wrapper.nix { };
  runescape-launcher-unwrapped = pkgs.callPackage ./pkgs/runescape-launcher { };
  xmake-dev = pkgs.callPackage ./pkgs/xmake-dev { };
  wl-clipboard-master = pkgs.callPackage ./pkgs/wl-clipboard-master { };
  riscv64-linux-gnu-toolchain = pkgs.callPackage ./pkgs/riscv64-linux-gnu-toolchain { };
}
