# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {}
}:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = pkgs.callPackage ./lib { nixTestRunner = nix-test-runner; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Integration tests.
  tests = pkgs.lib.callPackageWith
    (pkgs // { nurKollochLib = lib; } )
    ./tests {};

  # Packages.

  # Ripped from https://github.com/NixOS/nixpkgs/pull/82920
  jicofo = pkgs.callPackage ./pkgs/jitsi/jicofo {};
  jitsi-meet = pkgs.callPackage ./pkgs/jitsi/jitsi-meet {};
  jitsi-videobridge = pkgs.callPackage ./pkgs/jitsi/jitsi-videobridge {};

  # Rest
  nix-test-runner = (pkgs.callPackage ./pkgs/rust/nix-test-runner.nix {}).package;
  crate2nix = (pkgs.callPackage ./pkgs/rust/crate2nix.nix {}).package;
}

