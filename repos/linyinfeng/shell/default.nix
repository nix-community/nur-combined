{ lib, newScope, packages }:

lib.makeScope newScope (
  self:
  let
    inherit (self) callPackage;
  in
  {
    shell = callPackage ./shell.nix { };
    update = callPackage ./scripts/update.nix { inherit (packages) nvfetcher-changes-commit; };
    lint = callPackage ./scripts/lint.nix { };
  }
)
