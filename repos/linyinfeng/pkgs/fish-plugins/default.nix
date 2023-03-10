{ lib, newScope, fishPluginsToplevel }:

lib.makeScope newScope (self:
let
  inherit (self) callPackage;
in
{
  inherit (fishPluginsToplevel) buildFishPlugin;
  bang-bang = callPackage ./bang-bang { };
  git = callPackage ./git { };
  replay = callPackage ./replay { };
})
