# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

let
  pwnPackages = with pkgs; python-packages: with python-packages; [
    pwntools
    ipython
    ROPGadget
    r2pipe
    ropper
    unicorn
    z3
    capstone
  ];
in
rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  gospider = pkgs.callPackage ./pkgs/gospider { };
  ffuf = pkgs.callPackage ./pkgs/ffuf { };
  httpstat = pkgs.callPackage ./pkgs/httpstat { };
  easy-novnc = pkgs.callPackage ./pkgs/easy-novnc { };
  idafree = pkgs.callPackage ./pkgs/idafree { };
  burpsuite = pkgs.callPackage ./pkgs/burpsuite { };
  pwnPythonEnv = pkgs.python3.withPackages pwnPackages;
  pwnGdb = pkgs.gdb.override { python3 = pwnPythonEnv; };
}

