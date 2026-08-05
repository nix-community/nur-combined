# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: let
  discover = import ./internal/discover.nix {inherit (pkgs) lib;};
  sources = pkgs.callPackage ./_sources/generated.nix {};
  # Packages under pkgs/ are wired automatically; see internal/discover.nix
  # for the argument injection rules and the exception table semantics.
  packages = discover.packages {
    inherit pkgs sources;
    dir = ./pkgs;
    extraArgs = {
      typenix-vscode = {source = sources.typenix;};
    };
  };
in
  {
    # The `lib`, `overlays`, `nixosModules`, `homeModules`,
    # `darwinModules` and `flakeModules` names are special
    lib = import ./lib {inherit pkgs;}; # functions
    nixosModules = import ./nixos-modules {inherit (pkgs) lib;}; # NixOS modules
    homeModules = import ./home-modules {inherit (pkgs) lib;}; # Home Manager modules
    darwinModules = import ./darwin-modules {inherit (pkgs) lib;}; # nix-darwin modules
    # flakeModules = { }; # flake-parts modules
    overlays = import ./overlays; # nixpkgs overlays

    # Nested package sets without a top-level default.nix stay explicit.
    vscode-extensions = pkgs.lib.recurseIntoAttrs {
      ryanrasti = pkgs.lib.recurseIntoAttrs {
        typenix = pkgs.callPackage ./pkgs/vscode-extensions/ryanrasti/typenix {
          inherit (packages) typenix-vscode;
        };
      };
    };
  }
  // packages
