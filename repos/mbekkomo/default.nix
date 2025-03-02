# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }@attrs:
let
  inherit (attrs) emmylua-analyzer;
in
{
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  plutolang = pkgs.callPackage ./pkgs/plutolang { };
  jotdown = pkgs.callPackage ./pkgs/jotdown { };
  godjot = pkgs.callPackage ./pkgs/godjot { };
  sklauncher = pkgs.callPackage ./pkgs/sklauncher { };
  emmylua_ls = pkgs.callPackage emmylua-analyzer.emmylua_ls;
  emmylua_doc_cli = pkgs.callPackage emmylua-analyzer.emmylua_doc_cli;
  emmylua_check = pkgs.callPackage emmylua-analyzer.emmylua_check;
}
