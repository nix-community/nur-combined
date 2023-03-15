# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  amethyst = pkgs.callPackage ./packages/amethyst { };
  better-english = pkgs.callPackage ./packages/better-english { };
  trdsql-bin = pkgs.callPackage ./packages/trdsql-bin { };
  velociraptor-bin = pkgs.callPackage ./packages/velociraptor-bin { };
  vulnix-pre-commit = pkgs.callPackage ./packages/vulnix-pre-commit { };
}
