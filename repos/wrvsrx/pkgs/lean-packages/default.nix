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
    aesop = callPackage ./aesop { };
    batteries = callPackage ./batteries { };
    importGraph = callPackage ./importGraph { };
    plausible = callPackage ./plausible { };
    xdg = callPackage ./xdg { };
    Cli = callPackage ./Cli { };
    LeanSearchClient = callPackage ./LeanSearchClient { };
    Qq = callPackage ./Qq { };
  }
)
