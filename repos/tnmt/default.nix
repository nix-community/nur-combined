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
  # Only required for msgvault (bun2nix's fetchBunDeps + hook). Callers that
  # don't need msgvault can omit this.
  bun2nix ? null,
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

  brave-origin = pkgs.callPackage ./pkgs/brave-origin { };
  ax = pkgs.callPackage ./pkgs/ax { };
  chatgpt = pkgs.callPackage ./pkgs/chatgpt { };
  oneaws = pkgs.callPackage ./pkgs/oneaws { };
  kagiana = pkgs.callPackage ./pkgs/kagiana { };
  ccpocket-bridge = pkgs.callPackage ./pkgs/ccpocket-bridge { };
  mdhq = pkgs.callPackage ./pkgs/mdhq { };
  msgvault = pkgs.callPackage ./pkgs/msgvault { inherit bun2nix; };
  roots = pkgs.callPackage ./pkgs/roots { };
  givy = pkgs.callPackage ./pkgs/givy { };
  op-cached = pkgs.callPackage ./pkgs/op-cached { };
  symbol-desktop-wallet = pkgs.callPackage ./pkgs/symbol-desktop-wallet { };
}
