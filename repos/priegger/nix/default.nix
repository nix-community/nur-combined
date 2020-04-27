{ sources ? import ./sources.nix }:
with
{
  overlay = _: pkgs:
    {
      inherit (import sources.niv {}) niv;
      inherit (import sources.nixpkgs {}) nixpkgs-fmt;
    };
};
import sources.nixpkgs
  { overlays = [ overlay ]; config = {}; }
