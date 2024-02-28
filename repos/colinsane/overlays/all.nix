# this overlay exists specifically to control the order in which other overlays are applied.
# for example, `pkgs` *must* be added before `cross`, as the latter applies overrides
# to the packages defined in the former.

final: prev:
let
  pkgs = import ./pkgs.nix;
  preferences = import ./preferences.nix;
  cross = import ./cross.nix;

  isCross = prev.stdenv.hostPlatform != prev.stdenv.buildPlatform;
  ifCross = overlay: if isCross then overlay else (_: _: {});
  renderOverlays = overlays: builtins.foldl'
    (acc: thisOverlay: acc // (thisOverlay final acc))
    prev
    overlays;
in
  renderOverlays [
    pkgs
    preferences
    (ifCross cross)
  ]
