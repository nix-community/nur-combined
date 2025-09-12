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
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions

  example-package = pkgs.callPackage ./pkgs/example-package { };
  ez = pkgs.callPackage ./pkgs/ez { };
  wisdom-tree = pkgs.callPackage ./pkgs/wisdom-tree { };
  nohang = pkgs.callPackage ./pkgs/nohang { };
  blue-screen-of-life-grub = pkgs.callPackage ./pkgs/blue-screen-of-life-grub { };
  redlib = pkgs.callPackage ./pkgs/redlib { };
}
