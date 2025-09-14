# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  sunlightKernels = pkgs.callPackage ./pkgs/sunlight-kernels;
in
{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  linux_sunlight = sunlightKernels {
    variant = "mainline";
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.request_key_helper
    ];
  };

  linux_sunlight_stable = sunlightKernels {
    variant = "stable";
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.request_key_helper
    ];
  };
}
