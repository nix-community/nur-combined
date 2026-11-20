# The native Windows build entry point.
#
# nova-nix's package set lives in its source tree, so importing it here gives
# the recipe nova-nix's Windows stdenv without copying anything into the
# release directory.  `nova-nix build default.nix` loads this through
# flake-compat.nix on Windows.
{ nova-nix-src }:

let
  nova = import (nova-nix-src + "/pkgs/windows");
in
nova.lib.callPackageWith nova ./by-name/no/notepad-plus-plus/nova.nix { }
