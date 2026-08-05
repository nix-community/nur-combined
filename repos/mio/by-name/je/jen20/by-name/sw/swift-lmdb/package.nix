{
  lib,
  fetchFromGitHub,
  lmdb,
  makeSetupHook,
  pkg-config,
  stdenv,
  swift_release,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swift-lmdb";
  version = swift_release;

  src = fetchFromGitHub {
    owner = "swiftlang";
    repo = "swift-lmdb";
    tag = "swift-${finalAttrs.version}-RELEASE";
    hash = "sha256-jPtkUnCsfjBu4pJhaDw+umQivU0beTGSVoI2rIv8Mzg=";
  };

  strictDeps = true;

  propagatedBuildInputs = [ lmdb ];

  dontConfigure = true;
  dontBuild = true;

  # Instead of building it from source, use the existing package in Nixpkgs along with the provided modulemap.
  postInstall = ''
    mkdir -p "''${!outputDev}/lib/cmake/LMDB" "''${!outputDev}/include"

    substitute Sources/CLMDB/include/module.modulemap "''${!outputDev}/include/module.modulemap" \
      --replace-fail 'header "' 'header "${lib.getInclude lmdb}/include'

    # Install CMake config file for swift-lmdb.
    mkdir -p "''${!outputDev}/lib/cmake/LMDB"
    substitute ${./files/LMDBConfig.cmake} "''${!outputDev}/lib/cmake/LMDB/LMDBConfig.cmake" \
      --replace-fail '@buildType@' ${if stdenv.hostPlatform.isStatic then "STATIC" else "SHARED"} \
      --replace-fail '@dev@' "''${!outputDev}" \
      --replace-fail '@lib@' ${lib.escapeShellArg (lib.getLib lmdb)}
  '';

  passthru.devendorHook = makeSetupHook {
    name = "${finalAttrs.pname}-devendor-hook-${finalAttrs.version}";
    propagatedBuildInputs = [ pkg-config ];
    depsTargetTargetPropagated = [ lmdb ];
    substitutions = {
      devendorPatch = ./patches/devendor-lmdb.patch;
      lmdbInclude = lib.getInclude lmdb;
    };
  } ./setup-hook.sh;

  __structuredAttrs = true;

  meta = {
    homepage = "https://github.com/swiftlang/indexstore-db";
    description = "Source code indexing library";
    license = lib.licenses.asl20;
    teams = [ lib.teams.swift ];
  };
})
