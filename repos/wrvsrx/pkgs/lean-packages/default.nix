{
  sources,
  lib,
  newScope,
}:

lib.makeScope newScope (
  self:
  let
    inherit (self) callPackage;
    hooks = callPackage ./hooks { };
  in
  {
    inherit (hooks) lakeSetupHook;
    xdg = callPackage ./xdg { };
    batteries = callPackage ./batteries { };
    aesop = callPackage ./aesop { };
  }
)
