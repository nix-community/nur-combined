{ lib, newScope }:

let
  scope =
    self:
    let
      inherit (self) callPackage;
    in
    {
      modernx = callPackage ./modernx.nix { };
    };
in

with lib;
pipe scope [
  (makeScope newScope)
  recurseIntoAttrs
]
