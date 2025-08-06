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

  pinentry-touchid = pkgs.callPackage ./pkgs/pinentry-touchid { };
  # sncli = pkgs.callPackage ./pkgs/sncli { };
  ory.hydra = pkgs.callPackage ./pkgs/ory/hydra { };
  whereami = pkgs.callPackage ./pkgs/whereami { };
  openssl-tpm2-engine = pkgs.callPackage ./pkgs/openssl-tpm2-engine { };
  ibmtss = pkgs.callPackage ./pkgs/ibmtss { };
  # rusmux = pkgs.callPackage ./pkgs/rusmux { };
  wikit = pkgs.callPackage ./pkgs/wikit { };
  some-sass-language-server = pkgs.callPackage ./pkgs/some-sass-language-server { };
  # emmylua-analyzer-rust = pkgs.callPackage ./pkgs/emmylua-analyzer-rust { };
}
