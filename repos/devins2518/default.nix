# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # grub-holdshift = pkgs.callPackage ./pkgs/grub-holdshift { };
  bunnyfetch-rs = pkgs.callPackage ./pkgs/bunnyfetch-rs { };
  gyro = pkgs.callPackage ./pkgs/gyro { zig-master = zig-master-old; };
  iosevka-serif = pkgs.callPackage ./pkgs/iosevka-serif { };
  # midle = pkgs.callPackage ./pkgs/midle { };
  # paper = pkgs.callPackage ./pkgs/paper { };
  # ristate = pkgs.callPackage ./pkgs/ristate { };
  zig-master = pkgs.callPackage ./pkgs/zig-master { };
  zig-master-old = pkgs.callPackage ./pkgs/zig-master-old { };
  zigup = pkgs.callPackage ./pkgs/zigup { };
  zls = pkgs.callPackage ./pkgs/zls { zig-master = zig-master; };
}
