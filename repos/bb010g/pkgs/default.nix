{ pkgs, libExtension }:

let

pythonPkgsScoped = pkgs: super: {
  # so, this is cursed
  # we're going to override the root pythonInterpreters expression so both
  # deriving other overrides is easier and we can have universal python
  # overrides, because god is dead
  pythonInterpreters = let
    inherit (pkgs.lib)
      composeExtensions flow foldl' hideFunctionArgs mapAttr mapAttrOrElse
      mapFunctionArgs mapOptionalAttr;
    # we need a way to carry along overrides for all packages
    # i wrote this at one a.m. and somehow it pretty much just worked
    # (fixed points permanently bend your brain)
    attachScope = f: genSelf:
      let self = genSelf self // {
        overrideScope' = g: attachScope (composeExtensions f g) genSelf;
        overrideScopeGenSelf = g: attachScope f (g genSelf);
        scopeGenSelf = genSelf;
        scopeOverrides = f;
      }; in self;
    pi = attachScope (self: super: { }) (self:
      # override the `pkgs` used in `with pkgs;` to access `callPackage`
      super.pythonInterpreters.override (mapAttr "pkgs" (pkgs':
        # which we're hijacking just to get at one call involving an
        # `overrides` attrset argument
        mapAttr "callPackage" (callPackage:
          # yoink overrides and abuse it to drill
          fn: flow (mapAttrOrElse "overrides" (overrides:
            # walk backwards through the infinite-ish recursion of lib.fix'
            pySelf: pySuper: pySuper.__extends__ or (let
              # until we can insert our scope-y selves at the root
              # and take advantage of the specific way python-packages seals
              # itself up with its overrides
              pyScope = pkgs'.lib.makeScope pkgs'.newScope
                (pySelf': pySuper // { inherit (pySelf') callPackage; });
              in pyScope.overrideScope'
                (pkgs'.lib.composeExtensions self.scopeOverrides overrides))
          ) (_: s: s)) (callPackage fn)
        ) pkgs'
      ))
    );
  in pi;
};

allPackages = import ./top-level/all-packages.nix;

in let p = pkgs'; pkgs' = pkgs.appendOverlays [
  (pkgs: super: { lib = super.lib.extend libExtension; })
  pythonPkgsScoped
  (pkgs: super: {
    pythonPackagesScope = import ./top-level/python-packages.nix;
    pythonInterpreters = super.pythonInterpreters.overrideScope'
      pkgs.pythonPackagesScope;
  })
]; in p.lib.makeScope p.newScope (scopedPkgs: (p.lib.composeExtensionList [
  (self: super: { inherit (super) pythonPackagesScope; })
  allPackages
]) scopedPkgs p)
