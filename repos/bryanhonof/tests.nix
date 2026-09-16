# NixOS VM tests for this repository.
#
# Deliberately not reachable from default.nix: overlay.nix turns every
# non-reserved top-level attribute of that file into a nixpkgs overlay, so a
# `tests` attribute there would shadow upstream `pkgs.tests`.
#
# CI cannot run these either, having no KVM. Run one with
#     nix-build tests.nix -A ccache-storage-http
{
  pkgs ? import <nixpkgs> { },
}:

{
  ccache-storage-http = import ./tests/ccache-storage-http { inherit pkgs; };
}
