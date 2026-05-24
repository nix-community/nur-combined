{
  lib,
  stdenv,
  fetchFromCodeberg,
  cmake,
  pkg-config,
  lager,
  immer,
  zug,
  boost,
  nlohmann_json,
  vodozemac-bindings-kazv,
  cryptopp,
  libcpr,
  libhttpserver,
  libmicrohttpd,
  catch2_3,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  pname = "libkazv";
  version = "0.8.0-unstable-2026-05-23";

  src = fetchFromCodeberg {
    owner = "the-kazv-project";
    repo = "libkazv";
    rev = "d261c4d7c05f2e4e908de1069bce01c43b63feab";
    hash = "sha256-CKSOAsDeqYc3ekk3ovdpIYkYhbKQXXlWWFR5T6MFAFU=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    lager
    immer
    zug
    boost
    nlohmann_json
    vodozemac-bindings-kazv
    cryptopp

    libcpr
    libhttpserver
    libmicrohttpd
  ];

  strictDeps = true;
  enableParallelBuilding = true;

  cmakeFlags = [ (lib.cmakeBool "libkazv_BUILD_TESTS" finalAttrs.finalPackage.doCheck) ];

  doCheck = true;

  checkInputs = [ catch2_3 ];

  passthru.updateScript = unstableGitUpdater {
    tagPrefix = "v";
    tagFormat = "v*";
  };

  meta = {
    description = "Sans-io C++ (gnu++17) matrix client library";
    homepage = "https://lily-is.land/kazv/libkazv";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ xyenon ];
    platforms = lib.platforms.linux;
  };
})
