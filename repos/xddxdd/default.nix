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

  boringssl-oqs = pkgs.callPackage ./pkgs/boringssl-oqs { };
  libltnginx = pkgs.callPackage ./pkgs/libltnginx { };
  liboqs = pkgs.callPackage ./pkgs/liboqs { };
  linux-xanmod-lantian = pkgs.callPackage ./pkgs/linux-xanmod-lantian {
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.request_key_helper
    ];
  };
  openresty-lantian = pkgs.callPackage ./pkgs/openresty-lantian { };
  qemu-user-static = pkgs.callPackage ./pkgs/qemu-user-static { };
}
