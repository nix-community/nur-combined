{ lib, newScope, selfPackages, selfLib }:

lib.makeScope newScope (self:
let
  inherit (self) callPackage;
in
{
  updater = callPackage ./nvfetcher { };
  update = callPackage ./update {
    inherit selfLib selfPackages;
  };
})
