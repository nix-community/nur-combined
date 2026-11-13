# This file describes the repository contents.
# It returns a set of nix derivations and the special attributes `lib`,
# `overlays`, `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It does NOT import <nixpkgs> itself: pkgs is an argument. The <nixpkgs>
# default only allows short commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  # Every directory under ./pkgs is a package, named after the directory.
  # GoReleaser writes pkgs/<name>/default.nix on release, so new packages
  # show up here without editing this file.
  #
  # The names are built with builtins only: NUR's flake imports this file
  # with `pkgs = null` to read nixosModules and overlays, so building the
  # attribute set must not touch pkgs.
  pkgsDir = builtins.readDir ./pkgs;
  names = builtins.filter (n: pkgsDir.${n} == "directory") (builtins.attrNames pkgsDir);
  packages = builtins.listToAttrs (map
    (name: { inherit name; value = pkgs.callPackage (./pkgs + "/${name}") { }; })
    names);
in
packages // {
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  nixosModules = import ./nixos-modules; # NixOS modules
  # homeModules = { }; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays
}
