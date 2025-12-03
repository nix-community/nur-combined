# this overlay exists specifically to control the order in which other overlays are applied.
# for example, `pkgs` *must* be added before `cross`, as the latter applies overrides
# to the packages defined in the former.
let
  pkgs = import ./pkgs.nix;
  preferences = import ./preferences.nix;
  cross = import ./cross.nix;
  static = import ./static.nix;
  pkgs-ccache = import ./pkgs-ccache.nix;
  pkgs-debug = import ./pkgs-debug.nix;
in
final: prev:
let
  optional = cond: overlay: if cond then overlay else (_: _: {});
  isCross = !(prev.lib.systems.equals prev.stdenv.hostPlatform prev.stdenv.buildPlatform);
  # isCross = !(prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform);
  isStatic = prev.stdenv.hostPlatform.isStatic;
  renderOverlays = overlays: builtins.foldl'
    (acc: thisOverlay: acc // (thisOverlay final acc))
    prev
    overlays;
in
  renderOverlays [
    pkgs
    preferences
    (optional isCross cross)
    (optional isStatic static)
    pkgs-ccache
    pkgs-debug
  ]
