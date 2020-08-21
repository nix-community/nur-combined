# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  gralc = pkgs.callPackage ./pkgs/gralc { inherit sources; };

  pash = pkgs.callPackage ./pkgs/pash { inherit sources; };

  org-pretty-table = pkgs.callPackage ./pkgs/emacs-packages/org-pretty-table {inherit sources; };

  terminal-typeracer = pkgs.callPackage ./pkgs/terminal-typeracer { inherit sources; };
  
  torque = pkgs.callPackage ./pkgs/torque { inherit sources; };
  
  tremc = pkgs.callPackage ./pkgs/tremc { inherit sources; };
}

