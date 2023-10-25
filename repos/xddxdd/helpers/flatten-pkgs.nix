{
  lib,
  system,
  ...
}: let
  isDerivation = p: builtins.isAttrs p && p ? type && p.type == "derivation";
  isIndependentDerivation = p: isDerivation p && p.name != "merged-packages";
  isHiddenName = n: lib.hasPrefix "_" n || n == "stdenv";
  isTargetPlatform = p: lib.elem system (p.meta.platforms or [system]);
  shouldRecurseForDerivations = p: lib.isAttrs p && p.recurseForDerivations or false;

  flattenPkgs = prefix: s:
    builtins.filter
    ({
      name ? null,
      value ? null,
    }:
      name != null && value != null)
    (lib.flatten
      (lib.mapAttrsToList
        (n: p: let
          path =
            if prefix != ""
            then "${prefix}-${n}"
            else n;
        in
          if isHiddenName n
          then []
          else if !(builtins.tryEval p).success
          then []
          else if shouldRecurseForDerivations p
          then flattenPkgs path p
          else if isIndependentDerivation p && isTargetPlatform p
          then [
            {
              name = path;
              value = p;
            }
          ]
          else [])
        s));
in
  s: lib.listToAttrs (flattenPkgs "" s)
