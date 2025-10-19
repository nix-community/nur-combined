{
  pkgs ? import <nixpkgs> { },
}:
with builtins;
let
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isBuildable =
    p: !(p.meta.broken or false) && p.meta.license.free or true && !(p.meta.longBuild or false);
  isCacheable = p: !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p: isAttrs p && p.recurseForDerivations or false;

  nameValuePair = n: v: {
    name = n;
    value = v;
  };

  concatMap = builtins.concatMap or (f: xs: concatLists (map f xs));

  flattenPkgs =
    s:
    let
      f =
        p:
        if shouldRecurseForDerivations p then
          flattenPkgs p
        else if isDerivation p then
          [ p ]
        else
          [ ];
    in
    concatMap f (attrValues s);

  outputsOf = p: map (o: p.${o}) p.outputs;

  nurAttrs = import ./default.nix { inherit pkgs; };

  nurPkgs = flattenPkgs (
    listToAttrs (
      map (n: nameValuePair n nurAttrs.${n}) (filter (n: !isReserved n) (attrNames nurAttrs))
    )
  );

  nurOverlays = (import ./default.nix { }).overlays;
  fixedPkgs =
    let
      fixedPkgNames = attrNames (nurOverlays.fixes { } { });
      fixedNixpkgs = pkgs.lib.fix (pkgs.lib.extends nurOverlays.fixes (self: pkgs));
    in
    flattenPkgs (listToAttrs (map (n: nameValuePair n fixedNixpkgs.${n}) fixedPkgNames));
in
rec {
  # TODO build the overlayed lua & python packages?
  # Should probably add an ordering/priority value to the overlays so I can
  # consistently build a sorted list of them, then I just need need to pull the
  # attribute names from within each overlay and attempt to build those?
  buildPkgs = filter isBuildable (nurPkgs ++ fixedPkgs);
  cachePkgs = filter isCacheable buildPkgs;

  buildOutputs = concatMap outputsOf buildPkgs;
  cacheOutputs = concatMap outputsOf cachePkgs;
}
