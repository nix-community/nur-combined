# this scope isn't special in any way, except that `packagesFromDirectory` doesn't set `recurseIntoAttrs`, and this does.
# (that's needed for my update scripts to be found)
{
  lib,
  newScope,
}:
lib.recurseIntoAttrs (lib.makeScope newScope (self: with self; {
  mkNixpkgs = callPackage ./mkNixpkgs.nix { };
  master = callPackage ./master.nix { };
  nixpkgs-bootstrap-updater = callPackage ./nixpkgs-bootstrap-updater { };
  staging = callPackage ./staging.nix { };
  staging-next = callPackage ./staging-next.nix { };
}))
