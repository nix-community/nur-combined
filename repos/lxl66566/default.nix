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
  mylib = import ./lib { inherit pkgs; };
  callPackage = pkgs.newScope (pkgs // mylib);
in
{
  # The `lib`, `modules`, and `overlays` names are special
  lib = mylib; # functions
  nixosModules = import ./modules { }; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  audio-loudness-batch-normalize = callPackage ./pkgs/audio-loudness-batch-normalize { };
  fungi = callPackage ./pkgs/fungi { };
  git-simple-encrypt = callPackage ./pkgs/git-simple-encrypt { };
  git-sync-backup = callPackage ./pkgs/git-sync-backup { };
  openppp2 = callPackage ./pkgs/openppp2 { };
  system76-scheduler-niri = callPackage ./pkgs/system76-scheduler-niri { };
  user-startup-rs = callPackage ./pkgs/user-startup-rs { };
  xp3-pack-unpack = callPackage ./pkgs/xp3-pack-unpack { };
}
