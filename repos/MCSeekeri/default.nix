# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:

{
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  nixosModules = import ./nixos-modules; # NixOS modules
  # homeModules = { }; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays

  lain-kde-splashscreen = pkgs.callPackage ./pkgs/lain-kde-splashscreen { };
  cc-switch = pkgs.callPackage ./pkgs/cc-switch { };
  luker = pkgs.callPackage ./pkgs/luker { };
  metapi = pkgs.callPackage ./pkgs/metapi { };
  sub2api = pkgs.callPackage ./pkgs/sub2api { };
  tauritavern = pkgs.callPackage ./pkgs/tauritavern { };
  xmcl = pkgs.callPackage ./pkgs/xmcl { };
  xmcl-bin = pkgs.callPackage ./pkgs/xmcl-bin { };
  ai-toolbox = pkgs.callPackage ./pkgs/ai-toolbox { };
  fcitx5-vinput = pkgs.callPackage ./pkgs/fcitx5-vinput { };
  sabaki = pkgs.callPackage ./pkgs/sabaki { };
  savedesktop = pkgs.callPackage ./pkgs/savedesktop { };
  unreal-gold = pkgs.callPackage ./pkgs/unreal-gold { };
  pumpkin = pkgs.callPackage ./pkgs/pumpkin { };
}
