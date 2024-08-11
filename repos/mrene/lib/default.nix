{ lib, newScope }:

{
  scopeFromDirectoryRecursive = { directory }: 
    lib.makeScope newScope (self: lib.filesystem.packagesFromDirectoryRecursive{
      inherit (self) callPackage;
      inherit directory;
    });
}
