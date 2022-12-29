# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

with pkgs;

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  aws-cdk-local = callPackage ./pkgs/aws-cdk-local { };

  awscli-local = callPackage ./pkgs/awscli-local { };

  bundler = callPackage ./pkgs/bundler { };

  shadow-prod = callPackage ./pkgs/shadow-client {
    channel = "prod";
    enableDiagnostics = true;
    enableDesktopLauncher = true;
  };

  shadow-preprod = callPackage ./pkgs/shadow-client {
    channel = "preprod";
    enableDiagnostics = true;
    enableDesktopLauncher = true;
  };

  shadow-testing = callPackage ./pkgs/shadow-client {
    channel = "testing";
    enableDiagnostics = true;
    enableDesktopLauncher = true;
  };

  terraform-local = callPackage ./pkgs/terraform-local { };

}
