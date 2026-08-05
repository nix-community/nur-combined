{
  lib,
  cmake,
  fetchFromGitHub,
  fetchpatch2,
  ninja,
  stdenv,
  swift,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swift-system";
  version = "1.7.2";

  outputs = [
    "out"
    "dev"
  ];

  src = fetchFromGitHub {
    owner = "apple";
    repo = "swift-system";
    tag = finalAttrs.version;
    hash = "sha256-Gz+AljaS+/f9eK/jOTOdlOsrnyolgdPE+71TqfPpVts=";
  };

  patches = [
    ./patches/0001-gnu-install-dirs.patch
    # Install missing headers
    (fetchpatch2 {
      url = "https://github.com/apple/swift-system/commit/776989a95523068065d4e9f7904c62eceb48c183.patch?full_index=1";
      hash = "sha256-LRS2q2iiap0rmQXQV4NETpYVO518nqBKtKSDTCRwVBM=";
    })
  ];

  strictDeps = true;

  preConfigure = ''
    appendToVar cmakeFlags -DCMAKE_Swift_COMPILER_TARGET=${stdenv.hostPlatform.swift.triple}
    appendToVar cmakeFlags -DCMAKE_Swift_FLAGS=-module-cache-path\ "$NIX_BUILD_TOP/module-cache"
  '';

  nativeBuildInputs = [
    cmake
    ninja
    swift
  ];

  postInstall = ''
    moveToOutput lib/swift "''${!outputDev}"
    moveToOutput lib/swift_static "''${!outputDev}"

    # This isn’t installed by the upstream CMake files, but it’s needed.
    cp lib/libCSystem.a "$out/lib/libCSystem.a"

    # Install CMake config file for Swift System.
    mkdir -p "''${!outputDev}/lib/cmake/SwiftSystem"
    substitute ${./files/SwiftSystemConfig.cmake} "''${!outputDev}/lib/cmake/SwiftSystem/SwiftSystemConfig.cmake" \
      --replace-fail '@dev@' "''${!outputDev}" \
      --replace-fail '@lib@' "''${!outputLib}" \
      --replace-fail '@swiftPlatform@' ${stdenv.hostPlatform.swift.platform}
  '';

  __structuredAttrs = true;

  meta = {
    homepage = "https://github.com/apple/swift-system";
    description = "Low-level APIs and types for Swift";
    license = lib.licenses.asl20;
    teams = [ lib.teams.swift ];
  };
})
