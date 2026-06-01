# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  potracer = pkgs.python3Packages.callPackage ./pkgs/potracer { };
in
{
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  nixosModules = import ./nixos-modules; # NixOS modules
  # homeModules = { }; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays

  bb-imager = pkgs.callPackage ./pkgs/bb-imager-rs { withGui = true; };
  bb-imager-cli = pkgs.callPackage ./pkgs/bb-imager-rs { withGui = false; };
  cst = pkgs.callPackage ./pkgs/cst { };
  dtsfmt = pkgs.callPackage ./pkgs/dtsfmt { };
  envoluntary = pkgs.callPackage ./pkgs/envoluntary { };
  inherit potracer;
  supernote-tool = pkgs.python3Packages.callPackage ./pkgs/supernote-tool { inherit potracer; };
  trigger = pkgs.callPackage ./pkgs/trigger { };
  vscode-extensions = {
    mcu-debug.peripheral-viewer =
      pkgs.callPackage ./pkgs/vscode-extensions/mcu-debug.peripheral-viewer
        { };
    mcu-debug-rtos-views = pkgs.callPackage ./pkgs/vscode-extensions/mcu-debug.rtos-views { };
    nordic-semiconductor.nrf-devicetree =
      pkgs.callPackage ./pkgs/vscode-extensions/nordic-semiconductor.nrf-devicetree
        { };
    nordic-semiconductor.nrf-kconfig =
      pkgs.callPackage ./pkgs/vscode-extensions/nordic-semiconductor.nrf-devicetree
        { };
    nordic-semiconductor.nrf-terminal =
      pkgs.callPackage ./pkgs/vscode-extensions/nordic-semiconductor.nrf-terminal
        { };
    plorefice.devicetree = pkgs.callPackage ./pkgs/vscode-extensions/plorefice.devicetree { };
    yocto-project.yocto-bitbake =
      pkgs.callPackage ./pkgs/vscode-extensions/yocto-project.yocto-bitbake
        { };
  };
}
