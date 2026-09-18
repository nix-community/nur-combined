# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:
let
  lib = import ./lib { inherit pkgs; };
  callPackage =
    point:
    attrs@{
      lib ? { },
      ...
    }:
    pkgs.callPackage point (
      attrs
      // {
        lib = pkgs.lib // lib;
      }
    );
in
{
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  inherit lib;
  nixosModules = import ./nixos-modules; # NixOS modules
  # homeModules = { }; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays

  /*nixfmt:disable*/
  example-package = callPackage ./pkgs/example-package { };
  kwm-nightly     = callPackage ./pkgs/kwm-nightly { };
  kwim-nightly    = callPackage ./pkgs/kwim-nightly { };
  driftwm         = callPackage ./pkgs/driftwm { };
  driftwm-desktop = callPackage ./pkgs/driftwm-desktop { };
  driftmap        = callPackage ./pkgs/driftmap { };
  /*nixfmt:enable*/
}
