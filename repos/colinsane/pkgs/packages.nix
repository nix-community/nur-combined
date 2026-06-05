# use like `sane = import packages.nix { pkgs = import <nixpkgs> {}; }`.
# the resulting package set provides all my packages -- and only my packages --
# as an overridable scope.
#
# inner package sets like `mpvScripts` contain _only_ my mpvScripts and not nixpkgs' mpvScripts.
{
  lib,
  linuxPackages,
  mpvScripts,
  vimPlugins,
  newScope,
#--- optionals, if you want to support cross compilation ---
  pkgsBuildBuild ? {},
  pkgsBuildHost ? {},
  pkgsBuildTarget ? {},
  pkgsHostHost ? {},
  pkgsHostTarget ? {},
  pkgsTargetTarget ? {},
  ...
}:
lib.recurseIntoAttrs (
  lib.makeScope newScope (self:
  let
    sane = import ./unfixed.nix {
      inherit (self) callPackage newScope;
      inherit lib;
      otherSplices = lib.mapAttrs
        (_: pkgs: lib.optionalAttrs (pkgs ? lib) (import ./packages.nix pkgs))
        {
          selfBuildBuild = pkgsBuildBuild;
          selfBuildHost = pkgsBuildHost;
          selfBuildTarget = pkgsBuildTarget;
          selfHostHost = pkgsHostHost;
          selfHostTarget = pkgsHostTarget;
          selfTargetTarget = pkgsTargetTarget;
        }
      ;
    };
  in
    sane // {
      linuxPackages =
      let
        linuxPackagesAll = linuxPackages.extend (linuxFinal: _linuxPrev:
          sane.linuxPackages.packages linuxFinal
        );
      in
        sane.linuxPackages.overrideScope (_linuxFinal: _linuxPrev:
          sane.linuxPackages.packages linuxPackagesAll
        );

      mpvScripts =
      let
        mpvScriptsAll = mpvScripts.overrideScope (mpvScriptsFinal: _mpvScriptsPrev:
          sane.mpvScripts.packages mpvScriptsFinal
        );
      in
        sane.mpvScripts.overrideScope (_mpvScriptsFinal: _mpvScriptsPrev:
          sane.mpvScripts.packages mpvScriptsAll
        );

      # vimPlugins = ...  # XXX(2026-04-20): not needed because nixpkgs `vimPlugins` is an attrset, not a scope
    }
  )
)
