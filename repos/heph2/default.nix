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

  ### DEVELOPMENT
  # ansible-compat = pkgs.callPackage ./pkgs/python-modules/ansible-compat { };
  # molecule = pkgs.callPackage ./pkgs/python-modules/molecule { };
  # molecule-docker = pkgs.callPackage ./pkgs/python-modules/molecule-docker { };
  # molecule-hetznercloud = pkgs.callPackage ./pkgs/python-modules/molecule-hetznercloud { };
  # molecule-vagrant = pkgs.callPackage ./pkgs/python-modules/module-vagrant { };

  ### APPLICATION
  atlas = pkgs.callPackage ./pkgs/atlas { };
  ariel-dl = pkgs.callPackage ./pkgs/ariel-dl { };
  logisim-evolution = pkgs.callPackage ./pkgs/logisim-evolution { };
  telescope = pkgs.callPackage ./pkgs/telescope { };
  ndpi-dev = pkgs.callPackage ./pkgs/ndpi { };
  ndpid = pkgs.callPackage ./pkgs/ndpid { };
  google-cloud-sdk-auth-plugin = pkgs.callPackage ./pkgs/google-cloud-sdk-auth-plugin { };
}
