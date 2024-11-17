# this overlay exists specifically to control the order in which other overlays are applied.
# for example, `pkgs` *must* be added before `cross`, as the latter applies overrides
# to the packages defined in the former.
let
  pkgs = import ./pkgs.nix;
  preferences = import ./preferences.nix;
  cross = import ./cross.nix;
  pkgs-ccache = import ./pkgs-ccache.nix;
  pkgs-debug = import ./pkgs-debug.nix;
in
final: prev:
let

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
    pkgs-ccache
    pkgs-debug
  ]
