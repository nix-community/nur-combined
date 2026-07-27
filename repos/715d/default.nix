# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {
    overlays = [
      (import (builtins.fetchTarball {
        url = "https://github.com/oxalica/rust-overlay/archive/dbfd51be2692cb7022e301d14c139accb4ee63f0.tar.gz";
        sha256 = "1gkgkrsls53aqd5z6siqqbalp9mh0hh38k7fgqmax0n1w5j2caxm";
      }))
    ];
  }
}:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  unusedfunc = pkgs.callPackage ./pkgs/unusedfunc { };
  moon = pkgs.callPackage ./pkgs/moon { };
}
