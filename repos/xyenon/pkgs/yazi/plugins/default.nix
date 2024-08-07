{ lib, newScope }:

let
  scope =
    self:
    let
      inherit (self) callPackage;
    in
    {
      chmod = callPackage ./chmod.nix { };
      exifaudio = callPackage ./exifaudio.nix { };
      fg = callPackage ./fg.nix { };
      ouch = callPackage ./ouch.nix { };
    };
in

with lib;
pipe scope [
  (makeScope newScope)
  recurseIntoAttrs
]
