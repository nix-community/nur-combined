{
  lib, fetchgit, stdenv,
  cmake,
  ...
}:
let
  version = "8.9.0";
  rev = "CRYPTOPP_8_9_0";
  cmake-src = fetchgit {
    inherit rev;
    url = "https://github.com/abdes/cryptopp-cmake.git";
    hash = "sha256-+QWaQ8CSi4Jp22n1ubay7Mlyoe+em1ej9aR/1VMEJfA=";
  };
  src = fetchgit{
    inherit rev;
    url = "https://github.com/weidai11/cryptopp.git";
    hash = "sha256-HV+afSFkiXdy840JbHBTR8lLL0GMwsN3QdwaoQmicpQ=";
  };
in
stdenv.mkDerivation {
  inherit version;
  pname = "cryptopp-cmake";

  srcs = [ cmake-src ];

  nativeBuildInputs = [ cmake ];
  cmakeFlags = [
    "-DCRYPTOPP_BUILD_TESTING=OFF"
    "-DCRYPTOPP_SOURCES=${src}"
  ];
  patches = [
    ./patches/dir.patch
  ];

  meta = {
    homepage = "https://github.com/abdes/cryptopp-cmake";
    description = "Crypto++ library with CMake support";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes;[fromSource];
  };
}
