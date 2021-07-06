self: super: let
  arc = import ../canon.nix { inherit self super; };
  filterFnAttrs = fn: args: builtins.intersectAttrs (self.lib.functionArgs fn) args;
  pythonOverrides = builtins.removeAttrs self.pythonOverrides [ "recurseForDerivations" "extend" "__unfix__" ];
in {
  pythonOverlays = super.pythonOverlays or [ ] ++ [ (pself: psuper: builtins.mapAttrs (_: drv:
    if super.lib.isFunction drv then self.callPackage drv (filterFnAttrs drv {
      python = pself.python;
      pythonPackages = pself;
      pythonPackagesSuper = psuper;
    }) else drv
  ) pythonOverrides) ];
  pythonOverrides = super.lib.dontRecurseIntoAttrs or super.lib.id super.pythonOverrides or { };
  pythonInterpreters = builtins.mapAttrs (pyname: py:
    if py ? override
    then py.override (old: {
      packageOverrides = arc.super.lib.composeManyExtensions
        (super.lib.optional (old ? packageOverrides) old.packageOverrides ++ self.pythonOverlays);
    })
    else py
  ) super.pythonInterpreters;
}
