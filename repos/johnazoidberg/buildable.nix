# This file filters out all the unbuildable packages from your package set.
# It's what gets built by CI, so if you correctly mark broken/unfree packages
# as such your CI will not try to build them and the buildable packages will
# be added to the cache.
{ pkgs ? import <nixpkgs> {} }:

let
  filterSet =
    (f: g: s: builtins.listToAttrs
      (map
        (n: { name = n; value = builtins.getAttr n s; })
        (builtins.filter
          (n: f n && g (builtins.getAttr n s))
          (builtins.attrNames s)
        )
      )
    );
  isReserved = n: builtins.elem n ["lib" "overlays" "modules"];
  isBroken = p: p.meta.broken or false;
  isFree = p: p.meta.license.free or true;
in filterSet
     (n: !(isReserved n)) # filter out non-packages
     (p: (builtins.isAttrs p)
       && !(isBroken p)
       && isFree p
     )
     (import ./default.nix { inherit pkgs; })
