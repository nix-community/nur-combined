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
  version = "1.0.0-unstable-2026-11-04";

  src = fetchFromCodeberg {
    owner = "the-kazv-project";
    repo = "libkazv";
    rev = "4d1c8b10a7fd9a859dc74ed2bec29bc12e51963b";
    hash = "sha256-tHrzbephKoS4F/hlrQBF0nJSCH+T2bO86Qs5z/p2IIw=";
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
