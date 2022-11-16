{ lib, newScope, packages, selfLib }:

lib.makeScope newScope (
  self:
  let
    inherit (self) callPackage;
  in
  {
    shell = callPackage ./shell.nix { };
    update = callPackage ./scripts/update.nix {
      inherit selfLib;
      inherit (packages) nvfetcher-changes-commit;
      repoPackages = packages;
    };
    lint = callPackage ./scripts/lint.nix { };
  }
)
