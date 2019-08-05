{ pkgs, overlays ? (import ./default.nix).ordered }: let
  callOverlay = self: super:
  {
    callPackage = super.newScope self;
  };
  withOverlay = pkgs: if pkgs ? arc.__overlaid
    then pkgs
    else withOverlay' pkgs;
  applyOverlayList = overlays: pkgs:
    let
      inherit (pkgs) lib;
      extensions = lib.foldl' lib.composeExtensions (_: _: {}) overlays;
    in
    lib.fix (lib.extends extensions (self: pkgs));
  #withOverlay' = applyOverlayList (overlays ++ [callOverlay]);
  overlayScope = overlays: pkgs: let
    inherit (pkgs) lib;
    overlay = lib.foldl lib.composeExtensions (_: _: {}) overlays;
  in lib.makeScope pkgs.newScope (lib.flip overlay pkgs);
  withOverlay' = overlayScope overlays;
in
withOverlay pkgs
