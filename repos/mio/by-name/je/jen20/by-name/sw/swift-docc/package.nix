{
  lib,
  fetchFromGitHub,
  fetchSwiftPMDeps,
  lmdb,
  stdenv,
  swift,
  swift-lmdb,
  swiftpm,
  swift_release,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swift-docc";
  version = swift_release;

  src = fetchFromGitHub {
    owner = "swiftlang";
    repo = "swift-docc";
    tag = "swift-${finalAttrs.version}-RELEASE";
    hash = "sha256-zu70RyYvnfhW3DdovSeLFXTNmdHrhdnSYCN8RisSkt8=";
  };

  postPatch = ''
    # SignalTests.testTrappingSignal tries to access `/bin/bash`. Replace it with the shell in the stdenv.
    substituteInPlace Tests/SwiftDocCUtilitiesTests/SignalTests.swift \
      --replace-fail '/bin/bash' ${lib.escapeShellArg stdenv.shell}

    # SwiftLMDBTests.testVersion checks the LMDB version. Patch it to check for the version in Nixpkgs.
    substituteInPlace Tests/SwiftDocCTests/Utility/LMDBTests.swift \
      --replace-fail '0.9.70' ${lib.escapeShellArg (lib.getVersion lmdb)}
  '';

  strictDeps = true;

  swiftpmDeps = fetchSwiftPMDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-q3PZjzn2Zweyv5q2c4WgSe11FTp6EO3qxR/Qu3fOm6I=";
  };

  swiftpmFlags = [
    # Otherwise fails to build with `error: module 'SwiftDocC' was not compiled for testing`.
    "-Xswiftc"
    "-enable-testing"
  ];

  nativeBuildInputs = [
    swift
    swift-lmdb.devendorHook
    swiftpm
  ];

  doCheck = !stdenv.hostPlatform.isDarwin;

  __structuredAttrs = true;

  meta = {
    description = "Documentation compiler for Swift";
    mainProgram = "docc";
    homepage = "https://github.com/apple/swift-docc";
    platforms = with lib.platforms; linux ++ darwin;
    license = lib.licenses.asl20;
    teams = [ lib.teams.swift ];
  };
})
