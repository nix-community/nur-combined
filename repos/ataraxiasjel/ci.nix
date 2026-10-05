# This file provides all the buildable and cacheable packages and
# package outputs in your package set. These are what gets built by CI,
# so if you correctly mark packages as
#
# - broken (using `meta.broken`),
# - unfree (using `meta.license.free`), and
# - locally built (using `preferLocalBuild`)
#
# then your CI will be able to build and cache only those packages for
# which this is possible.

{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
  system ? pkgs.stdenv.hostPlatform.system,
}:

let
  inherit (lib) filterAttrs;
  inherit (builtins) attrNames isAttrs listToAttrs;

  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isNotBroken = p: !(p.meta.broken or false);
  isFree = p: p.meta.license.free or true;
  isCacheable = p: !(p.meta.preferLocalBuild or false);
  isUpdatable =
    p:
    isDerivation p
    && (p ? passthru && p.passthru ? updateScript && p.passthru.updateScript != null)
    && !(p.passthru.skipBulkUpdate or false);

  isBulkDuplicate =
    n:
    lib.hasSuffix "-full" n
    || n == "strudel-with-server"
    || n == "rosepine-gtk-icons"
    || n == "tokyonight-gtk-icons";

  shouldRecurseForDerivations = p: isAttrs p && p.recurseForDerivations or false;

  flattenAttrs =
    func: attrs:
    let
      op =
        acc: n:
        let
          v = attrs.${n};
          x =
            if shouldRecurseForDerivations v then
              flattenAttrs func v
            else if func v then
              { ${n} = v; }
            else
              { };
        in
        acc // x;
    in
    lib.foldl' op { } (lib.attrNames attrs);

  filterAttrsRec =
    func: attrs:
    listToAttrs (
      lib.concatMap (
        n:
        let
          v = attrs.${n};
        in
        if shouldRecurseForDerivations v then
          let
            sub = filterAttrsRec func v;
          in
          lib.optional (sub != { }) {
            name = n;
            value = sub;
          }
        else if func v then
          [
            {
              name = n;
              value = v;
            }
          ]
        else
          [ ]
      ) (lib.attrNames attrs)
    );

  nurAttrs = import ./pkgs/default.nix { inherit pkgs lib system; };
  nurPkgs = flattenAttrs isDerivation nurAttrs;

  pyExtensions = nurAttrs.pythonPackagesExtensions or [ ];
  pyExtended = pkgs.python3Packages.overrideScope (lib.composeManyExtensions pyExtensions);
  pyOurs = import ./pkgs/python3Packages {
    inherit (pyExtended) callPackage;
    inherit lib;
  };
  pyUpdatablePkgsRaw = filterAttrs (_: v: isUpdatable v && isNotBroken v) pyOurs;
in
rec {
  notReserved = filterAttrs (n: _: !(isReserved n)) nurAttrs;
  test = filterAttrsRec isUpdatable notReserved;
  updatablePkgs = filterAttrs (n: _: !(isBulkDuplicate n)) (
    flattenAttrs (p: isUpdatable p && isNotBroken p) nurAttrs
  );
  updatablePkgsNames = attrNames updatablePkgs;

  pyUpdatablePkgs = pyUpdatablePkgsRaw;
  pyUpdatablePkgsNames = attrNames pyUpdatablePkgsRaw;

  allPkgs = nurPkgs;
  buildPkgs = filterAttrs (_: v: isNotBroken v) allPkgs;
  cachePkgs = filterAttrs (_: v: isCacheable v) buildPkgs;
  freePkgs = filterAttrs (_: v: isFree v) buildPkgs;
}
