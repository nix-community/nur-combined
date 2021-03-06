# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? (import (fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz";
  sha256 = "sha256:1ckzhh24mgz6jd1xhfgx0i9mijk6xjqxwsshnvq789xsavrmsc36";
}) { }) }:
let
  util = pkgs.callPackage ./lib/util.nix { };
  beam = pkgs.callPackage ./pkgs/top-level/beam-packages.nix { inherit util; };
in util.recurseIntoAttrs (with beam; { inherit erlang pkg; })
