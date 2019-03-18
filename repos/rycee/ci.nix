# This file filters out all the broken packages from your package set.
# It's what gets built by CI, so if you correctly mark broken packages
# as broken your CI will not try to build them and the non-broken (and
# cacheable) packages will be added to the cache.
{ pkgs ? import <nixpkgs> {} }:

with builtins;

let

  isSpecial = n: n == "lib" || n == "overlays" || n == "modules";
  isBuildable = n: p: isAttrs p && !(p.meta.broken or false);
  isCacheable = n: p: isAttrs p && !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p: isAttrs p && p.recurseForDerivations or false;

  nameValue = n: v: { name = n; value = v; };

  filterDrvsRec = pred:
    let
      go = s:
        let
          f = n:
            let
              p = s.${n};
            in
              if shouldRecurseForDerivations p
                then [(nameValue n (go p))]
              else if pred n p
                then [(nameValue n p)]
              else if !isAttrs p then [(nameValue n p)]
              else [];
        in
          listToAttrs (concatMap f (attrNames s));
    in
      go;

  filterAttrs = f: s:
    listToAttrs
    (filter (n: !isSpecial n)
    (attrNames s));

  nurAttrs = import ./default.nix { inherit pkgs; };

  nurPkgs =
    listToAttrs
    (map (n: nameValue n nurAttrs.${n})
    (filter (n: !isSpecial n)
    (attrNames nurAttrs)));

in

rec {
  buildPkgs = filterDrvsRec isBuildable nurPkgs;
  cachePkgs = filterDrvsRec isCacheable buildPkgs;
}
