# Lists all buildable package attribute paths for use with nix-update
{ pkgs ? import <nixpkgs> { } }:

with builtins;
let
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isSupported = p: pkgs.lib.meta.availableOn { inherit (pkgs) system; } p;
  isBuildable = p: !(p.meta.broken or false) && isSupported p;
  shouldRecurseForDerivations = p: isAttrs p && p.recurseForDerivations or false;

  concatMap = builtins.concatMap or (f: xs: concatLists (map f xs));

  # Flatten packages while preserving attribute paths
  flattenPkgsWithPaths = s: prefix:
    let
      f = n: v:
        let
          path = if prefix == "" then n else "${prefix}.${n}";
        in
        if shouldRecurseForDerivations v then flattenPkgsWithPaths v path
        else if isDerivation v then [ { name = path; pkg = v; } ]
        else [ ];
    in
    concatMap (n: f n s.${n}) (attrNames s);

  nurAttrs = import ./default.nix { inherit pkgs; };

  nurPkgsWithPaths =
    flattenPkgsWithPaths
      (listToAttrs
        (map (n: { name = n; value = nurAttrs.${n}; })
          (filter (n: !isReserved n)
            (attrNames nurAttrs))))
      "";

  buildablePkgsWithPaths = filter (x: isBuildable x.pkg) nurPkgsWithPaths;

in
map (x: x.name) buildablePkgsWithPaths
