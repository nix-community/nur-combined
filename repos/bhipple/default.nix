# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = map import [
    ./overlays/ami.nix
    ./overlays/bhipple-nur-overlay.nix
    ./overlays/emacs-overlay.nix
    ./overlays/envs.nix
    ./overlays/hie.nix
    ./overlays/mkl.nix
    ./overlays/spacemacs.nix
  ];

  # gccemacs = pkgs.callPackage ./pkgs/gccemacs { };

  gccjit = pkgs.callPackage ./pkgs/gccjit/9 {
    isl = pkgs.isl_0_17;
    langJit = true;
    libcCross = null;
    noSysDirs = true;
    profiledCompiler = true;
    threadsCross = null;
  };

  gmpydl = pkgs.callPackage ./pkgs/gmpydl {};
  plaid2qif = pkgs.callPackage ./pkgs/plaid2qif {};

  # ledger-cli only gets a release every couple years; build the latest commit
  # off master.
  # ledger-git = pkgs.callPackage ./pkgs/ledger {};
}
