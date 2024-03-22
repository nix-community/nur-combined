# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

with pkgs; rec {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  hmModules = import ./hm-modules; # Home Manager modules
  overlays = import ./overlays; # nixpkgs overlays

  go-check = callPackage ./pkgs/go-check { };
  catp = callPackage ./pkgs/catp { };
  github-copilot-cli = callPackage ./pkgs/github-copilot-cli { };
  immer-unstable = callPackage ./pkgs/immer { };
  zug-unstable = callPackage ./pkgs/zug { };
  lager-unstable = callPackage ./pkgs/lager { inherit immer-unstable zug-unstable; };
  libkazv = callPackage ./pkgs/libkazv { inherit immer-unstable zug-unstable lager-unstable; };
  kazv = libsForQt5.callPackage ./pkgs/kazv { inherit libkazv; };
  nginxModules = callPackage ./pkgs/nginx/modules { };
  nginxStable = let nginxStable' = pkgs.nginxStable; in nginxStable'.override {
    modules = nginxStable'.modules ++ (with nginxModules; [
      (http_proxy_connect nginxStable'.version)
    ]);
  };
  nginxMainline = let nginxMainline' = pkgs.nginxMainline; in nginxMainline'.override {
    modules = nginxMainline'.modules ++ (with nginxModules; [
      (http_proxy_connect nginxMainline'.version)
    ]);
  };
  nginx = nginxStable;
  mpvScripts = callPackage ./pkgs/mpv/scripts { };
  anime4k = callPackage ./pkgs/anime4k { };
}
