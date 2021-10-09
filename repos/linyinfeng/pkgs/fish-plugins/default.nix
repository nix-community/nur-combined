{ lib, newScope, buildFishPlugin }:

lib.makeScope newScope (self:
  let
    inherit (self) callPackage;
  in
  {
    inherit buildFishPlugin;
    pisces = callPackage ./pisces { };
    plugin-bang-bang = callPackage ./plugin-bang-bang { };
    plugin-git = callPackage ./plugin-git { };
    replay-fish = callPackage ./replay-fish { };
  })
