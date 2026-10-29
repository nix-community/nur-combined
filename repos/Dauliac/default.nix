# Dauliac's NUR repository.
#
# This file describes the repository contents. It returns a set of nix
# derivations plus the special attributes NUR understands (`lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules`, `flakeModules`).
#
# It must NOT import <nixpkgs> itself - every dependency comes from the `pkgs`
# argument. Defaulting `pkgs` to <nixpkgs> is fine and enables `nix-build -A vsm`.
#
# NUR evaluates this with `--option restrict-eval true`, so every fetch must
# carry a hash and no package may force an unfree dependency at eval time.
# See pkgs/vsm for how the (BUSL-1.1, unfree) vault wrapper is kept opt-in.

{ pkgs ? import <nixpkgs> { } }:

{
  vsm = pkgs.callPackage ./pkgs/vsm { };
}
