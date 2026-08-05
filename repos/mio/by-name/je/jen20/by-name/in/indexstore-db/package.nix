{
  lib,
  cmake,
  fetchFromGitHub,
  ninja,
  stdenv,
  swift,
  swift-argument-parser,
  swift-corelibs-libdispatch,
  swift-lmdb,
  swift_release,
}:

let
  # IndexStoreDB is a dependency of Swift Testing.
  swift' = swift.override { swift-testing = null; };

  # Doesn’t require the Swift overlay.
  swift-corelibs-libdispatch' = swift-corelibs-libdispatch.override { useSwift = false; };

  rpaths = lib.makeLibraryPath [
    swift-lmdb.lmdb
    swift-argument-parser
    swift-corelibs-libdispatch'
  ];
in

stdenv.mkDerivation (finalAttrs: {
  pname = "indexstore-db";
  version = swift_release;

  outputs = [
    "out"
    "dev"
  ];

  src = fetchFromGitHub {
    owner = "swiftlang";
    repo = "indexstore-db";
    tag = "swift-${finalAttrs.version}-RELEASE";
    hash = "sha256-7jSNk/zamB3+UkHLC0xCIF0LhICMR3JQUlbTDd6t8jQ=";
  };

  patches = [ ./patches/0001-gnu-install-dirs.patch ];

  strictDeps = true;

  cmakeFlags = [ (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic)) ];

  preConfigure = ''
    appendToVar cmakeFlags -DCMAKE_Swift_COMPILER_TARGET=${stdenv.hostPlatform.swift.triple}
    appendToVar cmakeFlags -DCMAKE_Swift_FLAGS=-module-cache-path\ "$NIX_BUILD_TOP/module-cache"
  '';

  nativeBuildInputs = [
    cmake
    ninja
    swift'
  ];

  buildInputs = [
    swift-argument-parser
    swift-corelibs-libdispatch'
    swift-lmdb
  ];

  postInstall = ''
    moveToOutput lib/swift "''${!outputDev}"
    moveToOutput lib/swift_static "''${!outputDev}"

    # Install CMake config file for IndexStoreDB.
    mkdir -p "''${!outputDev}/lib/cmake/IndexStoreDB"
    substitute ${./files/IndexStoreDBConfig.cmake} "''${!outputDev}/lib/cmake/IndexStoreDB/IndexStoreDBConfig.cmake" \
      --replace-fail '@buildType@' ${if stdenv.hostPlatform.isStatic then "STATIC" else "SHARED"} \
      --replace-fail '@dev@' "''${!outputDev}" \
      --replace-fail '@lib@' "''${!outputLib}" \
      --replace-fail '@swiftPlatform@' ${stdenv.hostPlatform.swift.platform}
  ''
  + lib.optionalString stdenv.hostPlatform.isElf ''
    for output in "''${outputs[@]}"; do
      while IFS= read -d "" f; do
        if isELF "$f"; then
          patchelf --add-rpath ${lib.escapeShellArg rpaths} "$f"
        fi
      done < <(find "$output" -type f -print0)
    done
  '';

  __structuredAttrs = true;

  meta = {
    homepage = "https://github.com/swiftlang/indexstore-db";
    description = "Source code indexing library";
    license = lib.licenses.asl20;
    teams = [ lib.teams.swift ];
  };
})
