# Remove the pkgs set because it will cause issues with overlaying.

# We want to remove the "overlay" attr as well because it's not useful
# when using nix-extra with the NUR, as overlaying facilities already
# exist.

{ pkgs ? import <nixpkgs> {} }:

let
  default = import ./default.nix {
    inherit pkgs;
  };
in builtins.removeAttrs default [ "pkgs" "overlay" ]
