
{ lib, newScope }:

# We can't recursively load packages because lib.filesystem.packagesFromDirectoryRecursive would load the current
# directory and go into infinite recursion :(
lib.recurseIntoAttrs (lib.makeScope newScope (self: 
let 
  callPackage = self.callPackage;
in
{
  gr-foo = callPackage ./gr-foo/package.nix { };
  gr-ieee-802-15-4 = callPackage ./gr-ieee-802-15-4/package.nix { };
  gr-pdu_utils = callPackage ./gr-pdu_utils/package.nix { };
  gr-sandia_utils = callPackage ./gr-sandia_utils/package.nix { };
  gr-timing_utils = callPackage ./gr-timing_utils/package.nix { };
  gr-fhss_utils = callPackage ./gr-fhss_utils/package.nix { };
  gr-smart_meters = callPackage ./gr-smart_meters/package.nix { };
}))