/*
  We have to ignore additional parameters passed to us as Nix 2.4 is injecting `inNixShell` without checking if the called expression actually wants it
  See: https://github.com/NixOS/nix/pull/5543
*/
{ ... }:
let
  sources = import ./sources.nix;
in
import sources.nixpkgs {
  overlays = [
    (self: super: {
      npmlock2nix = self.callPackage ../default.nix { };
      inherit (import sources.smoke { }) smoke;
      nix-pre-commit-hooks = import (sources.nix-pre-commit-hooks);
    })
  ];
}
