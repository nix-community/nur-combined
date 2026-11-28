{
  lib,
}:

lib.extend (
  finalLib: _prevLib: {
    recurseIntoPackageSets = import ./recurseIntoPackageSets.nix { lib = finalLib; };
  }
)
