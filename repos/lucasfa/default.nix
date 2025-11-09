# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
  #config,
  #kernel ? config.boot.kernelPackages.kernel,
}:

let
  libslimbook = pkgs.callPackage ./pkgs/libslimbook { };
in
{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  libslimbook = libslimbook;
  python-slimbook = pkgs.callPackage ./pkgs/python-slimbook { inherit libslimbook; };
  # qc71_slimbook_laptop is available under the overlay
  #qc71_slimbook_laptop = pkgs.callPackage ./pkgs/os-specific/linux/qc71_slimbook_laptop {
    # Make sure the module targets the same kernel as your system is using.
    #inherit kernel;
    #kernel = kernel ? config.boot.kernelPackages.kernel;
  #};
}
