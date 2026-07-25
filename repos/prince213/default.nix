{
  pkgs ? import <nixpkgs> { },
}:
let
  overlay = import ./pkgs/top-level/all-packages.nix;
in
{
  overlays.default = overlay;
}
// overlay (pkgs.extend overlay) pkgs
