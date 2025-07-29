{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> {inherit system;},
}: {
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # packages
  bobgen = pkgs.callPackage ./pkgs/bobgen {};
  bumper = pkgs.callPackage ./pkgs/bumper {};
  nix-update = pkgs.callPackage ./pkgs/nix-update {};
  protoc-gen-connect-openapi = pkgs.callPackage ./pkgs/protoc-gen-connect-openapi {};
  opengrep = pkgs.callPackage ./pkgs/opengrep {};
  renovate = pkgs.callPackage ./pkgs/renovate {};
  shellhook = pkgs.callPackage ./pkgs/shellhook {};
}
