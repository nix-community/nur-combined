{
  lib,
  stdenv,
  fetchFromGitLab,
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
  version = "0.7.0-unstable-2024-10-26";

  src = fetchFromGitLab {
    domain = "lily-is.land";
    owner = "kazv";
    repo = "libkazv";
    rev = "2976174ee367db694b73785b985a9e797cd9aa35";
    hash = "sha256-aPEEPZdYijsNKUEjNt5dXtABOJFMni8L4CGu/jONqRw=";
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

  cmakeFlags = [ (lib.cmakeBool "libkazv_BUILD_TESTS" finalAttrs.doCheck) ];

  doCheck = true;

  checkInputs = [ catch2_3 ];

  passthru.updateScript = unstableGitUpdater { tagPrefix = "v"; };

  meta = with lib; {
    description = "A sans-io C++ (gnu++17) matrix client library";
    homepage = "https://lily-is.land/kazv/libkazv";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ xyenon ];
  };
})
