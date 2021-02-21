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
  overlays = import ./overlays; # nixpkgs overlays

  pythonWithPipenv = pkgs.callPackage ./pkgs/pythonWithPipenv { };
  multiEclipse = pkgs.callPackage ./pkgs/multiEclipse { };
  mumble_ptt_caps_lock_led = pkgs.callPackage ./pkgs/mumble_ptt_caps_lock_led { 
    buildPythonPackage = pkgs.python38Packages.buildPythonPackage; 
    fetchPypi = pkgs.python38Packages.fetchPypi;
    pydbus = pkgs.python38Packages.pydbus;
    pygobject = pkgs.python38Packages.pygobject3;
  };
}

