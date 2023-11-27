{ lib, newScope, selfPackages, selfLib }:

lib.makeScope newScope (self:
let
  inherit (self) callPackage;
in
{
  nvfetcher-self = callPackage ./nvfetcher-self { };
})
