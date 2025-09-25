{
  sources,
  lib,
  newScope,
}:

let
  scope =
    self:
    let
      inherit (self) callPackage;
    in
    {
      exifaudio = callPackage ./exifaudio.nix { };
      clipboard = callPackage ./clipboard.nix { };
      fg = callPackage ./fg { };
      ouch = callPackage ./ouch.nix { };
      yazi-rs = callPackage ./yazi-rs { source = sources.yazi-rs-plugins; };
    };
in

with lib;
pipe scope [
  (makeScope newScope)
  recurseIntoAttrs
]
