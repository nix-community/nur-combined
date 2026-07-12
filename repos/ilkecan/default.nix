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

let
  modules = import ./modules;
  repo = {
    # The `lib`, `modules`, and `overlays` names are special
    lib = import ./lib { inherit pkgs; }; # functions
    inherit modules; # modules
    overlays = import ./overlays; # nixpkgs overlays

    # ... as well as `xxxModules`, see: https://github.com/nix-community/NUR/pull/1101
    flakeModules = modules.flake;
    homeModules = modules.homeManager;
    nixosModules = modules.nixos;

    fmodstudio = pkgs.callPackage ./pkgs/fmodstudio { inherit (repo) icu56; }; # https://github.com/NixOS/nixpkgs/pull/491823
    icu56 = pkgs.callPackage ./pkgs/icu56 { }; # https://github.com/NixOS/nixpkgs/pull/491823
    keyguard = pkgs.callPackage ./pkgs/keyguard { }; # https://github.com/NixOS/nixpkgs/pull/495316
    wl-find-cursor = pkgs.callPackage ./pkgs/wl-find-cursor { }; # github.com/NixOS/nixpkgs/pull/504085
    zellij-autolock = pkgs.callPackage ./pkgs/zellij-autolock { };
    zellij-workspace = pkgs.callPackage ./pkgs/zellij-workspace { };
  };
in
repo
