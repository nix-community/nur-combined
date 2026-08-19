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
  # Keep npm lockfile repair scoped to packages in this repository.
  packagePkgs = pkgs.extend (import ./internal/npm-lockfile-fix.nix);
  # Auto-wire packages under pkgs/; `extraArgs` handles exceptions.
  packages = discover.packages {
    pkgs = packagePkgs;
    inherit sources;
    dir = ./pkgs;
    extraArgs = {
      typenix-vscode = {source = sources.typenix;};
    };
  };
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
