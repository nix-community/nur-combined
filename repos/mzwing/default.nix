# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: let
  packages = import ./internal/packages.nix {inherit pkgs;};
in
  {
    # Reserved NUR exports.
    lib = import ./lib {inherit pkgs;}; # functions
    nixosModules = import ./nixos-modules; # NixOS modules
    homeModules = import ./home-modules; # Home Manager modules
    darwinModules = import ./darwin-modules; # nix-darwin modules
    # flakeModules = { }; # flake-parts modules
    overlays = import ./overlays; # nixpkgs overlays

    # Explicit nested package set.
    vscode-extensions = pkgs.lib.recurseIntoAttrs {
      ryanrasti = pkgs.lib.recurseIntoAttrs {
        typenix = pkgs.callPackage ./pkgs/vscode-extensions/ryanrasti/typenix {
          inherit (packages) typenix-vscode;
        };
      };
    };
  }
  // packages
