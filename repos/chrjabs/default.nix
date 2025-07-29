# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{
  pkgs ? import <nixpkgs> { },
}:
rec {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # VeriPB proof checker
  veripb = pkgs.python3Packages.callPackage ./pkgs/veripb { };
  pboxide = pkgs.callPackage ./pkgs/pboxide { };

  # GBD benchmark database
  gbd = pkgs.python3Packages.callPackage ./pkgs/gbd { inherit gbdc; };
  gbdc = pkgs.python3Packages.callPackage ./pkgs/gbdc { };
  # Only the GBDC executable
  gbdc-tool = pkgs.callPackage ./pkgs/gbdc/tool.nix { };

  # Python MIP
  python-mip = pkgs.python311Packages.callPackage ./pkgs/python-mip { };
}
