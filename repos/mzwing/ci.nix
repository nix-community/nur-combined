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
# environment of an impure evaluation), source-built packages are wrapped
# with compiler caches (sccache for Rust, GOCACHE for Go) pointing at a
# persistent directory mounted into the CI builders' Nix sandbox. This is
# meant for CI only; local builds are unaffected.
{
  pkgs ? import <nixpkgs> {},
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
  rustCachedNames = ["ace-ctx" "autocli" "pumpkin"];
  goCachedNames = ["cliproxyapiplus" "sing-box-alpha" "sing-box-beta"];

  applyCompileCache = entry: let
    name = concatStringsSep "." entry.attrPath;
  in
    if !compileCache
    then entry
    else if elem name rustCachedNames
    then
      entry
      // {
        package = entry.package.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.sccache];
          RUSTC_WRAPPER = "sccache";
          SCCACHE_DIR = "${compileCacheDir}/sccache";
          SCCACHE_CACHE_SIZE = "2G";
          # Builds on one builder run as different nixbld users; world-
          # writable cache entries let all of them share the directory.
          # ($out permissions are canonicalized by Nix after the build.)
          preBuild =
            (old.preBuild or "")
            + ''
              umask 000
              mkdir -p "$SCCACHE_DIR"
            '';
          # umask 000 makes $out group/other-writable, which Nix rejects as
          # "suspicious ownership or permission"; strip those bits again.
          postFixup =
            (old.postFixup or "")
            + ''
              find "$out" -type f -exec chmod go-w {} +
              find "$out" -type d -exec chmod go-w {} +
            '';
        });
      }
    else if elem name goCachedNames
    then
      entry
      // {
        package = entry.package.overrideAttrs (old: {
          # Exported in preBuild so it wins over any GOCACHE set by the
          # nixpkgs Go setup hook.
          preBuild =
            (old.preBuild or "")
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

  nurAttrs = import ./default.nix {inherit pkgs;};
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
