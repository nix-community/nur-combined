# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

let
  pkgs' = pkgs.extend (self: super: {
    config = (super.config or {}) // {
      sources = (super.config.sources or {}) // import ./sources;
    };
  });

  haskell = pkgs: import ./pkgs/haskell { inherit (pkgs) lib haskell; };
  ocaml-ng = import ./pkgs/ocaml { inherit (pkgs') lib ocaml-ng; };
  pkgsh = pkgs'.extend (_: pkgs: { haskell = haskell pkgs; });

  inherit (pkgs') callPackage;
in {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit (pkgs') lib; }; # functions
  modules = import ./modules/nixos; # NixOS modules
  hmModules = import ./modules/home-manager;
  overlays = import ./overlays; # nixpkgs overlays

  haskell = haskell pkgs';
  inherit (pkgsh.haskellPackages) bibi;

  inherit ocaml-ng;
  inherit (ocaml-ng.ocamlPackages_4_07) patoline;

  shellFileBin =  callPackage ./pkgs/build-support/shellFileBin {};

  zsh-prompt-gentoo = callPackage ./pkgs/zsh-prompt-gentoo {};
}
