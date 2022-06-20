{ lib, newScope, buildFishPlugin, pkgsFishPlugins }:

lib.makeScope newScope (self:
let
  inherit (self) callPackage;
in
{
  inherit buildFishPlugin;
  bang-bang = callPackage ./bang-bang { };
  git = callPackage ./git { };
  replay = callPackage ./replay { };
} // lib.optionalAttrs (! (pkgsFishPlugins ? pisces)) {
  pisces = callPackage ./pisces { };
})
