{ callPackage, ... }:
{
  mkUpdateChecker = callPackage ./update-checker { };
}
