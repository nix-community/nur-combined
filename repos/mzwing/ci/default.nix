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
#
# When `compileCache` is enabled (or NUR_COMPILE_CACHE=1 is set in the
# environment of an impure evaluation), source-built Go packages are
# wrapped with a persistent GOCACHE directory mounted into the CI
# builders' Nix sandbox. This is meant for CI only; local builds are
# unaffected. (Rust packages use crane for caching instead; see
# default.nix.)
{
  pkgs ? import <nixpkgs> {},
  craneLib ? null,
  compileCache ? (builtins.getEnv "NUR_COMPILE_CACHE") == "1",
}:
with builtins; let
  reservedNames = [
    "lib"
    "overlays"
    "nixosModules"
    "homeModules"
    "darwinModules"
    "flakeModules"
  ];

  isDerivation = value: isAttrs value && value ? type && value.type == "derivation";
  isFreeLicense = license: !isAttrs license || license.free or true;
  isBuildable = package: let
    meta = package.meta or {};
    license = meta.license or [];
    licenses =
      if isList license
      then license
      else [license];
  in
    pkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform package
    && !(meta.broken or false)
    && all isFreeLicense licenses;
  isCacheable = package: !(package.preferLocalBuild or false);
  shouldRecurseForDerivations = value: isAttrs value && value.recurseForDerivations or false;

  concatMap = builtins.concatMap or (function: values: concatLists (map function values));

  flattenPkgs = attrPath: packageSet:
    concatMap
    (name: let
      value = packageSet.${name};
      nestedPath = attrPath ++ [name];
    in
      if shouldRecurseForDerivations value
      then flattenPkgs nestedPath value
      else if isDerivation value
      then [
        {
          inherit (value) outputs;
          attrPath = nestedPath;
          package = value;
        }
      ]
      else [])
    (attrNames packageSet);

  outputsOf = entry:
    map
    (outputName: {
      inherit (entry) attrPath package;
      inherit outputName;
      output = entry.package.${outputName};
    })
    entry.outputs;

  targetOf = entry: {
    inherit (entry) attrPath outputName;
    name = concatStringsSep "." entry.attrPath;
    system = pkgs.stdenv.hostPlatform.system;
    outputPath = entry.output.outPath;
  };

  compileCacheDir = "/opt/nur-ci-compile-cache";
  goCachedNames = ["cliproxyapiplus" "sing-box-alpha" "sing-box-beta"];

  applyCompileCache = entry: let
    name = concatStringsSep "." entry.attrPath;
  in
    if !compileCache
    then entry
    else if elem name goCachedNames
    then
      entry
      // {
        package = entry.package.overrideAttrs (old: {
          # This must go in postConfigure, not preBuild: buildGoModule's
          # goModules FOD inherits preBuild (and would fail with world-
          # writable output due to umask 000), while postConfigure is not
          # inherited and still runs after configurePhase's default
          # GOCACHE export, so our value wins.
          postConfigure =
            (old.postConfigure or "")
            + ''
              umask 000
              export GOCACHE=${compileCacheDir}/gocache
              mkdir -p "$GOCACHE"
            '';
          # See the Rust branch above.
          postFixup =
            (old.postFixup or "")
            + ''
              find "$out" -type f -exec chmod go-w {} +
              find "$out" -type d -exec chmod go-w {} +
            '';
        });
      }
    else entry;

  nurAttrs = import ../default.nix {inherit pkgs craneLib;};
  nurEntries = map applyCompileCache (flattenPkgs [] (removeAttrs nurAttrs reservedNames));
in rec {
  buildEntries = filter (entry: isBuildable entry.package) nurEntries;
  cacheEntries = filter (entry: isCacheable entry.package) buildEntries;

  buildPkgs = map (entry: entry.package) buildEntries;
  cachePkgs = map (entry: entry.package) cacheEntries;

  buildOutputEntries = concatMap outputsOf buildEntries;
  cacheOutputEntries = concatMap outputsOf cacheEntries;

  buildOutputs = map (entry: entry.output) buildOutputEntries;
  cacheOutputs = map (entry: entry.output) cacheOutputEntries;

  buildTargets = map targetOf buildOutputEntries;
  cacheTargets = map targetOf cacheOutputEntries;
}
