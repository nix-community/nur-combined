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
    aesop = callPackage ./aesop { source = sources.aesop; };
    batteries = callPackage ./batteries { source = sources.batteries; };
    importGraph = callPackage ./importGraph { source = sources.importGraph; };
    mathlib = callPackage ./mathlib { source = sources.mathlib; };
    plausible = callPackage ./plausible { source = sources.plausible; };
    xdg = callPackage ./xdg { source = sources.xdg; };
    Cli = callPackage ./Cli { source = sources.Cli; };
    LeanSearchClient = callPackage ./LeanSearchClient { source = sources.LeanSearchClient; };
    proofwidgets = callPackage ./proofwidgets { source = sources.proofwidgets; };
    Qq = callPackage ./Qq { source = sources.Qq; };
  }
)
