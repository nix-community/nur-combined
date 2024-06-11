{ lib, newScope }:

lib.makeScope newScope (
  self: with self; {
    modernx = callPackage ./modernx.nix { };
  }
)
