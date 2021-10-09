{ lib, newScope, buildFishPlugin }:

lib.makeScope newScope (self:
  let
    inherit (self) callPackage;
  in
  {
    inherit buildFishPlugin;
    plugin-git = callPackage ./plugin-git { };
  })
