# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  ytmdl = pkgs.callPackage ./pkgs/ytmdl {
    bs4 = pkgs.callPackage ./pkgs/bs4 {
      python38Packages = pkgs.python38Packages;
    };
    simber = pkgs.callPackage ./pkgs/simber {
      python38Packages = pkgs.python38Packages;
    };
    pydes = pkgs.callPackage ./pkgs/pydes {
      python38Packages = pkgs.python38Packages;
    };
    downloader-cli = pkgs.callPackage ./pkgs/downloader-cli {
      fetchFromGitHub = pkgs.fetchFromGitHub;
      python38Packages = pkgs.python38Packages;
    };
    itunespy = pkgs.callPackage ./pkgs/itunespy {
      python38Packages = pkgs.python38Packages;
    };
    youtube-search = pkgs.callPackage ./pkgs/youtube-search {
      python38Packages = pkgs.python38Packages;
    };
    python38Packages = pkgs.python38Packages;
  };
}
