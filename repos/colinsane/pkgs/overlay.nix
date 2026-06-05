# use like `import <nixpkgs> { overlays = ./overlay.nix; }`.
# this cleanly merges my own packages into the nixpkgs namespace,
# e.g. the resulting `pkgs.mpvScripts` contains both nixpkgs' mpvScripts and my own,
# in the same, overridable, scope.
self: super:
let
  sane = import ./unfixed.nix {
    inherit (self) callPackage newScope;
    inherit (super) lib;
    otherSplices = {
      selfBuildBuild = self.pkgsBuildBuild;
      selfBuildHost = self.pkgsBuildHost;
      selfBuildTarget = self.pkgsBuildTarget;
      selfHostHost = self.pkgsHostHost;
      selfHostTarget = self.pkgsHostTarget;
      selfTargetTarget = self.pkgsTargetTarget;
    };
  };
  warnIfDef = new: prev: builtins.mapAttrs
    (name: value:
      super.lib.warnIf (builtins.hasAttr name prev && !(value.shadowNixpkgs or false)) "package ${name} shadows upstream package of same name" value
    )
    new
  ;
  # these forms below cause infinite recursion but i don't understand why:
  # sane = self.callPackage ./unfixed.nix { inherit (super) lib; };
  # sane = import ./unfixed.nix self;
  # sane = import ./unfixed.nix (self // {
  #   inherit (super) lib;
  # });
in
  (warnIfDef
    (removeAttrs sane [
      # nixpkgs generates `linuxPackages` via `kernelPackagesExtensions`:
      # `sane.linuxPackages` is removed here, and re-expressed as an extension, below
      "linuxPackages"
    ])
    super
  ) // {
    kernelPackagesExtensions = super.kernelPackagesExtensions ++ [
      (kFinal: kPrev:
        warnIfDef
          (sane.linuxPackages.packages kFinal)
          kPrev
      )
    ];
    mpvScripts = super.mpvScripts.overrideScope (mpvScriptsFinal: mpvScriptsPrev:
      warnIfDef
        (sane.mpvScripts.packages mpvScriptsFinal)
        mpvScriptsPrev
    );
    # XXX(2026-04-20): nixpkgs `vimPlugins` is a bare attrset -- not a scope
    vimPlugins = super.vimPlugins // (
      warnIfDef
        (sane.vimPlugins.packages sane.vimPlugins)
        super.vimPlugins
    );
  }
