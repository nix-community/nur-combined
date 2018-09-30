{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  otcl = pkgs.callPackage ./pkgs/otcl { };
  tclcl = pkgs.callPackage ./pkgs/tclcl { inherit otcl; };
  ns-2 = pkgs.callPackage ./pkgs/ns2 { inherit otcl tclcl; };
}

