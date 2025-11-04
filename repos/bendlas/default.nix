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

  lsd = pkgs.callPackage ./pkgs/lsd.nix { };
  zsh-capture-completion = pkgs.callPackage ./pkgs/zsh-capture-completion.nix { };
  ueforth = pkgs.callPackage ./pkgs/ueforth.nix { };
  gd32-dfu-utils = pkgs.callPackage ./pkgs/gd32-dfu-utils.nix { };
  openocd-riscv = pkgs.callPackage ./pkgs/openocd-riscv.nix {
    inherit libgpiod1;
  };
  libgpiod1 = pkgs.callPackage ./pkgs/libgpiod1.nix { };

}
