# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

let
  unstable_ = pkgs.fetchFromGitHub {
    owner = "nixos";
    repo = "nixpkgs";
    rev = "1a57d96edd156958b12782e8c8b6a374142a7248";
    sha256 = "1qdh457apmw2yxbpi1biwl5x5ygaw158ppff4al8rx7gncgl10rd";
  };
  unstable = import unstable_ { config.allowUnfree = true; };
  eval = import <nixpkgs/nixos/lib/eval-config.nix>;
  config = eval {modules = [(import <nixos-config>)];}.config;
in {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules { unstable = unstable_; }; # NixOS modules
  overlays = import ./overlays { inherit unstable config; }; # nixpkgs overlays

  example-package = pkgs.callPackage ./pkgs/example-package { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
  k380-function-keys-conf = pkgs.callPackage ./pkgs/k380-function-keys-conf { };
  knobkraft-orm = pkgs.callPackage ./pkgs/knobkraft-orm { };
  realrtcw = pkgs.callPackage ./pkgs/realrtcw { };
  gamescope = pkgs.callPackage ./pkgs/gamescope {};
}

