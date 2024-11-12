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

  abella-modded = pkgs.callPackage ./pkgs/abella-modded {
    ocamlPackages = pkgs.ocaml-ng.ocamlPackages_4_12;
  };

  autosubst-ocaml = pkgs.coqPackages_8_19.callPackage ./pkgs/coqPackages/autosubst-ocaml {};

  ott-sweirich = pkgs.callPackage ./pkgs/ott-sweirich {
    ocamlPackages = pkgs.ocaml-ng.ocamlPackages_4_12;
  };
}
