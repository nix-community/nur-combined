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
  vodozemac-bindings-kazv-unstable,
  cryptopp,
  libcpr,
  libhttpserver,
  libmicrohttpd,
  catch2_3,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libkazv";
  version = "0.8.0-unstable-2026-03-14";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "the-kazv-project";
    repo = "libkazv";
    rev = "3b750c126d5568b19e9ead65cebef8ba3edb585c";
    hash = "sha256-GpPzMracvaFWS/nGiPZHRH0+ck64eAa/ppb7fANIVvU=";
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
    vodozemac-bindings-kazv-unstable
    cryptopp

    libcpr
    libhttpserver
    libmicrohttpd
  ];

  strictDeps = true;

  cmakeFlags = [ (lib.cmakeBool "libkazv_BUILD_TESTS" finalAttrs.finalPackage.doCheck) ];

  doCheck = true;

  checkInputs = [ catch2_3 ];

  passthru.updateScript = unstableGitUpdater {
    tagPrefix = "v";
    tagFormat = "v*";
  };

  meta = with lib; {
    description = "Sans-io C++ (gnu++17) matrix client library";
    homepage = "https://lily-is.land/kazv/libkazv";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ xyenon ];
  };
})
