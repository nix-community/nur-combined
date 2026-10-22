# CI build/cache selection rules.
#
# This file is NOT part of the NUR export surface (`default.nix` does not
# reference it); `flake.nix` imports it to derive `ciPackages` / `ciJobs`.

{ lib, exports }:

let
  reservedAttrs = [
    "lib"
    "modules"
    "overlays"
  ];

  isDerivation = p: lib.isAttrs p && (p.type or null) == "derivation";

  isBuildable =
    p:
    let
      licenses = p.meta.license or [ ];
    in
    !(p.meta.broken or false) && lib.all (license: license.free or true) (lib.toList licenses);

  isCacheable = p: !(p.preferLocalBuild or false);

  flattenPkgs =
    set:
    lib.concatMap (
      p:
      if lib.isAttrs p && (p.recurseForDerivations or false) then
        flattenPkgs p
      else
        lib.optional (isDerivation p) p
    ) (lib.attrValues set);

  exportedAttrs = lib.filterAttrs (n: _: !(lib.elem n reservedAttrs)) exports;
in
builtins.filter isCacheable (builtins.filter isBuildable (flattenPkgs exportedAttrs))
