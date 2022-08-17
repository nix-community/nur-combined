{callPackage, ...}: {
  lib = {
    forceCached = callPackage ./force-cached {};
  };
}
