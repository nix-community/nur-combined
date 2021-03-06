# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  hm = home-manager;
  home-manager = hmModules;
  hmModules = rec {
    modules = pkgs.lib.attrValues rawModules;
    rawModules = import ./home-manager/modules;
    machines = import ./home-manager/modules/machines.nix;

    base = import ./home-manager/modules/home/base-pkgs.nix { inherit pkgs; };
    ui = import ./home-manager/modules/home/ui-pkgs.nix { inherit pkgs; };

  };

  # packages
  shot = pkgs.callPackage ./pkgs/shot { };
  kubectx = pkgs.callPackage ./pkgs/kubectx { };
  haskellPackages = import ./pkgs/haskellPackages { inherit pkgs; };
  emacs = pkgs.callPackage ./pkgs/emacs { };
}

