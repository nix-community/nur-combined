{ sources ? import ./sources.nix }:
with
{
  overlay = _: pkgs:
    {
      inherit (import sources.niv { }) niv;
      inherit (import sources.unstable { }) nixpkgs-fmt;
    };
};
import
  sources.nixpkgs
{ overlays = [ overlay ]; config = { }; }
