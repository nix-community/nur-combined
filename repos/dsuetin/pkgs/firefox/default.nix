{ callPackage, lib }:

{
  userjs = lib.recurseIntoAttrs (callPackage ./userjs { });
}
