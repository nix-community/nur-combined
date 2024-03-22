# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  aprsgateway = pkgs.callPackage ./pkgs/aprsgateway { };
  dapnetgateway = pkgs.callPackage ./pkgs/dapnetgateway { };
  dmrgateway = pkgs.callPackage ./pkgs/dmrgateway { };
  metty = pkgs.callPackage ./pkgs/metty { };
  mmdvmhost = pkgs.callPackage ./pkgs/mmdvmhost { };
  satorictl-unstable = pkgs.callPackage ./pkgs/satorictl-unstable { };
}
