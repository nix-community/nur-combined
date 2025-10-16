# This file provides all the buildable and cacheable packages and
# package outputs in your package set. These are what gets built by CI,
# so if you correctly mark packages as
#
# - broken (using `meta.broken`),
# - unfree (using `meta.license.free`),
# - platform-specific (using `meta.platform` and `meta.badPlatforms`), and
# - uncacheable (using `allowSubstitutes`)
#
# then your CI will be able to build and cache only those packages for
# which this is possible.

{
  platform ? null,
  subsetName ? "all",
  pkgs ? import <nixpkgs> (if platform != null then {
    localSystem = platform;
    packageOverrides = pkgs: {
      inherit (import <nixpkgs> {}) fetchurl fetchgit fetchzip; # Don't emulate curl and such
    };
  } else {}),
  cachedBuildFailures ? null,
}:

with builtins;
let
  inherit (pkgs) lib;
  subsets = {
    all = p: true;
    base = p: !(lib.any (subset: subset p) (attrValues (removeAttrs subsets ["all" "base"])));
    
    hbmame = p: lib.hasInfix "hbmame" (p.name or "");
    mame = p: lib.hasInfix "mame" (p.name or "") && !(subsets.hbmame p);
    qemu-screamer = p: lib.hasInfix "qemu" (p.name or "") && lib.hasInfix "screamer" (p.name or "");
    big-electron = p: lib.hasInfix "shapez" (p.name or "") && (lib.systems.elaborate p.system).isDarwin;
  };
  subset = subsets.${subsetName};
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isBuildable = p: let
    licenseFromMeta = p.meta.license or [];
    licenseList = if builtins.isList licenseFromMeta then licenseFromMeta else [licenseFromMeta];
  in
    lib.meta.availableOn pkgs.stdenvNoCC.hostPlatform p &&
    !(p.meta.broken or false) &&
    (p._Rhys-T.allowCI or true) &&
    builtins.all (license: license.free or true) licenseList &&
    (p.meta.knownVulnerabilities or []) == []
  ;
  isCacheable = p: (p.allowSubstitutes or true);
  shouldRecurseForDerivations = p: isAttrs p && p.recurseForDerivations or false;

  nameValuePair = n: v: { name = n; value = v; };

  concatMap = builtins.concatMap or (f: xs: concatLists (map f xs));

  flattenPkgs = s:
    let
      f = p:
        if shouldRecurseForDerivations p then flattenPkgs p
        else if isDerivation p then [ p ]
        else [ ];
    in
    concatMap f (attrValues s);

  outputsOf = p: map (o: p.${o}) p.outputs;

  nurAttrs' = import ./default.nix { inherit pkgs; };
  nurAttrs = nurAttrs' // lib.optionalAttrs (nurAttrs'?_ciOnly) {
    _ciOnly = lib.recurseIntoAttrs nurAttrs'._ciOnly;
  };

  nurPkgs =
    flattenPkgs
      (listToAttrs
        (map (n: nameValuePair n nurAttrs.${n})
          (filter (n: !isReserved n)
            (attrNames nurAttrs))));

in
rec {
  buildPkgs = filter isBuildable nurPkgs;
  cachePkgs' = filter isCacheable buildPkgs;
  cachePkgs'' = filter subset cachePkgs';
  cachePkgs = if cachedBuildFailures != null then
    let
      cachedBuildFailurePathForDrv = p: cachedBuildFailures + "/${builtins.unsafeDiscardStringContext (baseNameOf p.drvPath)}.json";
      notCachedBuildFailure = p: !(p?drvPath && pathExists (cachedBuildFailurePathForDrv p));
      results = lib.partition notCachedBuildFailure cachePkgs'';
    in results.right ++ lib.optional (builtins.length results.wrong > 0) (pkgs.runCommandLocal "_Rhys-T-replayed-cached-errors" {
      failureInfo = builtins.toJSON (map (p: lib.importJSON (cachedBuildFailurePathForDrv p)) (filter (p: p?drvPath) results.wrong));
    } ''
      echo "error: derivation(s) matched build failure cache:" >&2
      ${with pkgs; lib.getExe jq} -r '.[] | "error:     \(.drv_path) - https://github.com/\(.repository)/actions/runs/\(.run_id)/job/\(.job_id)\(if .attempt != "1" then "/attempts/"+.attempt else "" end)"' <<< "$failureInfo" >&2
      echo "error: end of replayed build failures" >&2
      exit 1
    '')
  else cachePkgs'';

  buildOutputs = concatMap outputsOf buildPkgs;
  cacheOutputs = concatMap outputsOf cachePkgs;
  cacheOutputsAsAttrs = builtins.listToAttrs (lib.imap0 (i: x: lib.nameValuePair ("_${toString i}-${builtins.replaceStrings ["."] ["_"] x.name}") x) cacheOutputs);
}
