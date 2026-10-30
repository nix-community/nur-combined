# Wraps stdenv.mkDerivation with gleamErlangHook or gleamJavascriptHook,
# building `gleamDeps` from manifest.toml (read from the source, or `manifest`),
# so a hash isn't needed.
#
# Hex packages are fetched with their checksums from the manifest. It only has
# the commit of git packages, so they're fetched with builtins.fetchGit during
# evaluation. Local packages are used from the source by gleam directly, their
# gleam.toml is fingerprinted like gleam does.
#
# build/packages/packages.toml is written like gleam writes it after
# downloading, so `gleam deps download` in gleamConfigHook doesn't download
# anything. The dependency derivation is named without the version, and only
# changes with the manifest's packages and the local packages' gleam.toml.
#
# With `gleamDepsHash`, `gleamDeps` is fetched with gleamFetchDeps instead, so
# the source isn't read during evaluation (no import from derivation).
#
# With `gleamLibrary`, the package is built with `gleam build` and its HTML
# docs are installed instead of an executable. `gleam test` runs by default.
{
  beamMinimalPackages,
  callPackage,
  lib,
  runCommandLocal,
  stdenv,
  xxhash,
}:

let
  gleamFetchDeps = callPackage ../gleamFetchDeps { };

  hooks = {
    erlang = callPackage ../gleamErlangHook { };
    javascript = callPackage ../gleamJavascriptHook { };
  };

  # path of a file relative to the unpacked source, inside `src`
  srcPath =
    {
      src,
      sourceRoot ? null,
    }:
    file:
    lib.concatStringsSep "/" (
      [ "${src}" ]
      ++ lib.filter (part: part != "" && part != ".") (
        lib.optionals (sourceRoot != null) (lib.drop 1 (lib.splitString "/" sourceRoot))
        ++ lib.splitString "/" file
      )
    );

  fetchPackage =
    package:
    if package.source == "hex" then
      beamMinimalPackages.fetchHex {
        pkg = package.name;
        inherit (package) version;
        sha256 = package.outer_checksum;
      }
    else
      let
        repo = fetchGit {
          url = package.repo;
          rev = package.commit;
          allRefs = true;
        };
      in
      if package ? path then "${repo}/${package.path}" else repo;

  mkPackagesToml =
    packages:
    lib.concatStrings (
      [ "[packages]\n" ]
      ++ map (package: "${package.name} = ${builtins.toJSON package.version}\n") packages
      ++ map (
        package:
        "\n[git.${package.name}]\ncommit = ${builtins.toJSON package.commit}\n"
        + lib.optionalString (package ? path) "path = ${builtins.toJSON package.path}\n"
      ) (lib.filter (package: package.source == "git") packages)
    );

  # gleam resolves the versions again without a fingerprint of each local
  # package's gleam.toml (xxh3_64 as a decimal), which needs the network
  writeFingerprint =
    manifest: package:
    let
      config = builtins.toFile "gleam.toml" (
        builtins.unsafeDiscardStringContext (
          builtins.readFile (dirOf manifest + "/${package.path}/gleam.toml")
        )
      );
    in
    ''
      hash=$(xxhsum -H3 ${config} | cut -d ' ' -f 1)
      printf '%u' "0x''${hash#XXH3_}" > $out/packages/${package.name}.config_fingerprint
    '';

  mkGleamDeps =
    { pname, manifest }:
    let
      packages = (lib.importTOML manifest).packages or [ ];
      local = lib.filter (package: package.source == "local") packages;
      fetched = lib.filter (package: package.source != "local") packages;
    in
    runCommandLocal "${pname}-gleam-deps"
      {
        nativeBuildInputs = [ xxhash ];
        packagesToml = mkPackagesToml packages;
        passAsFile = [ "packagesToml" ];
      }
      ''
        mkdir -p $out/packages
        cp "$packagesTomlPath" $out/packages/packages.toml
        ${lib.concatMapStrings (
          package: "cp -r ${lib.escapeShellArg (fetchPackage package)} $out/packages/${package.name}\n"
        ) fetched}
        ${lib.concatMapStrings (writeFingerprint manifest) local}
      '';
in

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;

  excludeDrvArgNames = [
    "gleamDepsHash"
    "gleamTarget"
    "manifest"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      src,
      sourceRoot ? null,
      gleamRoot ? null,
      # "erlang" or "javascript"
      gleamTarget ? "erlang",
      # path to manifest.toml, to read it from somewhere other than the source
      manifest ? srcPath { inherit src sourceRoot; } "${toString gleamRoot}/manifest.toml",
      # hash of gleamFetchDeps, to fetch the dependencies without reading the
      # manifest during evaluation. "" to get it from the hash mismatch.
      gleamDepsHash ? null,
      # build a library and install its docs, instead of an app
      gleamLibrary ? false,
      doCheck ? true,
      nativeBuildInputs ? [ ],
      ...
    }@args:

    assert lib.assertMsg (
      hooks ? ${gleamTarget}
    ) "mkGleamPackage: gleamTarget must be \"erlang\" or \"javascript\"";

    assert lib.assertMsg (
      gleamDepsHash == null || !(args ? manifest)
    ) "mkGleamPackage: manifest isn't used with gleamDepsHash";

    let
      pname = args.pname or (lib.getName args.name);
    in
    {
      gleamDeps =
        args.gleamDeps or (
          if gleamDepsHash != null then
            gleamFetchDeps (
              {
                inherit pname src;
                hash = gleamDepsHash;
              }
              # attributes that can change the manifest's location or contents
              // lib.intersectAttrs {
                sourceRoot = null;
                gleamRoot = null;
                prePatch = null;
                patches = null;
                postPatch = null;
              } args
            )
          else
            mkGleamDeps { inherit pname manifest; }
        );

      inherit gleamLibrary doCheck;

      nativeBuildInputs = nativeBuildInputs ++ [ hooks.${gleamTarget} ];
    };
}
