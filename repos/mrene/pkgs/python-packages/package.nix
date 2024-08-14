{ lib, newScope }:

# We can't recursively load packages because lib.filesystem.packagesFromDirectoryRecursive would load the current
# directory and go into infinite recursion :(
lib.recurseIntoAttrs (lib.makeScope newScope (self: 
let 
  callPackage = self.callPackage;
in
{
  
}))