# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  maintainer = {
    github = "Adamekka";
    githubId = 68786400;
    name = "Adamekka";
  };
in
{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  # MARK: Packages

  gdstash = pkgs.callPackage ./pkgs/gdstash { inherit maintainer; };
  lsfg-vk-git = pkgs.callPackage ./pkgs/lsfg-vk-git { inherit maintainer; };
  lunar-tear = pkgs.callPackage ./pkgs/lunar-tear { inherit maintainer; };
  rpcs3-git = pkgs.callPackage ./pkgs/rpcs3-git { inherit maintainer; };
  wondershaper = pkgs.callPackage ./pkgs/wondershaper { inherit maintainer; };
}
