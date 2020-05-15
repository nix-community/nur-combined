# Remove the pkgs set because it will
# cause issues with overlaying.

{ pkgs ? import <nixpkgs> {} }:

let
  default = import ./default.nix {
    inherit pkgs;
  };
in builtins.removeAttrs default [ "pkgs" ]