{ pkgs }:
with builtins;
let
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  shouldRecurseForDerivations = p: isAttrs p && p.recurseForDerivations or false;
  flattenPkgs_ =
    s:
    let
      f =
        p:
        if shouldRecurseForDerivations p.value then
          flattenPkgs_ (pkgs.lib.attrsToList p.value)
        else if isDerivation p.value then
          [ p ]
        else
          [ ];
    in
    concatMap f s;
  flattenPkgs = s: listToAttrs (flattenPkgs_ (pkgs.lib.attrsToList s));
in
flattenPkgs
