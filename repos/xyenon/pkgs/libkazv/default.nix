{
  lib,
  stdenv,
  fetchFromGitea,
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
  version = "0.8.0-unstable-2026-05-10";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "the-kazv-project";
    repo = "libkazv";
    rev = "5d1dcb91cacdea97bcb1d066966430b2a102c2bc";
    hash = "sha256-XKw7S++NapQ5BnHGV2Cw6htpcY2kLhhB5KeLgVcyx9E=";
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
