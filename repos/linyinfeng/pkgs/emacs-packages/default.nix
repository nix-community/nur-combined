{ lib, newScope, emacsPackagesToplevel }:

lib.makeScope newScope (self:
let
  inherit (self) callPackage;
in
{
  inherit (emacsPackagesToplevel) trivialBuild;
  pyim-greatdict = callPackage ./pyim-greatdict { };
})
