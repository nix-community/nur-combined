{ lib, newScope }:

lib.makeScope newScope (
  self:
  let
    inherit (self) callPackage;
  in
  {
    shell = callPackage ./shell.nix { };
    update = callPackage ./scripts/update.nix { };
    lint = callPackage ./scripts/lint.nix { };
  }
)
