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
    rev = "63ee5cd99a2e193d5e4c879feb9683ddec23fa03";
    sha256 = "0avbsx5chbwr0y55shndkzf0ixx3bznbzq526p5nj8llryxa10af";
  };
  unstable = import unstable_ { config.allowUnfree = true; };
  eval = import <nixpkgs/nixos/lib/eval-config.nix>;
  config = eval {modules = [(import <nixos-config>)];}.config;
in rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules { unstable-path = unstable_; inherit unstable; }; # NixOS modules
  overlays = import ./overlays { inherit unstable config; }; # nixpkgs overlays

  k380-function-keys-conf = pkgs.callPackage ./pkgs/k380-function-keys-conf.nix { };
  knobkraft-orm = pkgs.callPackage ./pkgs/knobkraft-orm.nix { };
  realrtcw = pkgs.callPackage ./pkgs/realrtcw.nix { };
  gamescope = pkgs.callPackage ./pkgs/gamescope.nix {};
  re3 = pkgs.callPackage ./pkgs/re3.nix {};
  revc = pkgs.callPackage ./pkgs/revc.nix { inherit re3; };
  bitwig-studio3 = pkgs.callPackage ./pkgs/bitwig-studio3.nix {};
}

