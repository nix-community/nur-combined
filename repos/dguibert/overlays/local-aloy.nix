self: super:
let
  overlay = (super.lib.composeOverlays [
   (import ./local-genji.nix)
  ]);
in overlay self super
