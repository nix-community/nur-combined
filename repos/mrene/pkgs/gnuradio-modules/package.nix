
{ lib, callPackage, newScope }:

# We can't recursively load packages because lib.filesystem.packagesFromDirectoryRecursive would load the current
# directory and go into infinite recursion :(
lib.recurseIntoAttrs (lib.makeScope newScope (self: 
let 
  callPackage = self.callPackage;
in
{
  gr-foo = callPackage ./gr-foo/package.nix { };
  gr-ieee-802-15-4 = callPackage ./gr-ieee-802-15-4/package.nix { };
}))