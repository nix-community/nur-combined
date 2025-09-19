# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ inputs ? builtins.getFlake ./., pkgs ? import <nixpkgs> { } }:

rec {
  noriskclient-launcher-unwrapped = pkgs.callPackage ./pkgs/noriskclient-launcher-unwrapped { inputs = inputs; };
  noriskclient-launcher = pkgs.callPackage ./pkgs/noriskclient-launcher { noriskclient-launcher-unwrapped = noriskclient-launcher-unwrapped; };
}
