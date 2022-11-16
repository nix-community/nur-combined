{ lib }:

let
  getSingle = p: lib.optional (p ? updateScriptEnabled && p.updateScriptEnabled && p ? updateScript) p.updateScript;
  getRec =
    p:
    if lib.isDerivation p then getSingle p
    else if lib.isAttrs p && p ? recurseForDerivations && p.recurseForDerivations
    then lib.concatLists (lib.mapAttrsToList (n: p': getRec p') p)
    else [ ];
in
packages: getRec (lib.recurseIntoAttrs packages)
