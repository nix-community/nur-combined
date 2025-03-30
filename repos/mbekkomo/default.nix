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
{
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  plutolang = pkgs.callPackage ./pkgs/plutolang { };
  jotdown = pkgs.callPackage ./pkgs/jotdown { };
  godjot = pkgs.callPackage ./pkgs/godjot { };
  sklauncher = pkgs.callPackage ./pkgs/sklauncher { };
  emmylua-codestyle = pkgs.callPackage ./pkgs/emmylua-codestyle { };
  luakit_2_4 = pkgs.callPackage ./pkgs/luakit_2_4 { };
  wihotspot = pkgs.callPackage ./pkgs/wihotspot { };
  # sourcetrail = pkgs.callPackage ./pkgs/sourcetrail { };
}
// builtins.mapAttrs (name: deriv: pkgs.callPackage deriv { }) (import ./pkgs/emmylua-analyzer)
