{
  lib,
  cmake,
  fetchFromGitHub,
  ninja,
  stdenv,
  swift,
  swift-syntax,
  swift_release,
}:

let
  inherit (stdenv.hostPlatform.extensions) sharedLibrary;
  buildSharedLibrary = stdenv.buildPlatform.extensions.sharedLibrary;

  # For some reason, building swift-testing without swift-driver fails to build.
  swift' = swift.override {
    #    swift-foundation = null;
    swift-testing = null;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "swift-testing";
  version = swift_release;

  outputs = [
    "out"
    "dev"
  ];

  src = fetchFromGitHub {
    owner = "swiftlang";
    repo = "swift-testing";
    tag = "swift-${finalAttrs.version}-RELEASE";
    hash = "sha256-HgvwoAbUeFTVnrOTNVIgFRLOpGyCQHRgQqulHQ1LYnQ=";
  };

  patches = [ ./patches/0001-gnu-install-dirs.patch ];

  postPatch = ''
    # Need to reference $include, so this can’t be substituted by `replaceVars`.
    substituteInPlace CMakeLists.txt --replace-fail '@include@' "''${!outputInclude}"
  '';

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

  buildInputs = [ swift-syntax ];

  postInstall = (
    if stdenv.hostPlatform.isDarwin then
      ''
        install -D -t "''${!outputDev}/lib/swift/host/plugins/testing" \
          lib/swift/host/plugins/testing/libTestingMacros${sharedLibrary}
        install_name_tool "''${!outputLib}/lib/libTesting${sharedLibrary}" \
          -id "''${!outputLib}/lib/libTesting${sharedLibrary}"
        install_name_tool "''${!outputDev}/lib/swift/host/plugins/testing/libTestingMacros${buildSharedLibrary}" \
          -id "''${!outputDev}/lib/swift/host/plugins/testing/libTestingMacros${buildSharedLibrary}"
      ''
    else
      ''
        install -D -t "''${!outputDev}/lib/swift/host/plugins/testing" \
          lib/swift/host/plugins/libTestingMacros${sharedLibrary}
      ''
  );

  __structuredAttrs = true;

  meta = {
    description = "Modern testing package for Swift";
    homepage = "https://github.com/swiftlang/swift-testing";
    platforms = with lib.platforms; darwin ++ linux ++ windows;
    license = lib.licenses.asl20;
    maintainers = lib.teams.swift.members;
  };
})
