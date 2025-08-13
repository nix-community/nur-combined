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
  nix-fix-hash = pkgs.callPackage ./pkgs/nix-fix-hash {};
  nix-update = pkgs.callPackage ./pkgs/nix-update {};
  opengrep = pkgs.callPackage ./pkgs/opengrep {};
  protoc-gen-connect-openapi = pkgs.callPackage ./pkgs/protoc-gen-connect-openapi {};
  renovate = pkgs.callPackage ./pkgs/renovate {};
  shellhook = pkgs.callPackage ./pkgs/shellhook {};
}
