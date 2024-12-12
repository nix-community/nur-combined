{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

let
  boost_crc = fetchFromGitHub {
    owner = "boostorg";
    repo = "crc";
    tag = "boost-1.86.0";
    hash = "sha256-SzPDNHX9arnnZNWf/RedbSw1UwqTNuZCxVmegXHANgY=";
  };
  catch2 = fetchFromGitHub {
    owner = "catchorg";
    repo = "Catch2";
    tag = "v3.7.1";
    hash = "sha256-Zt53Qtry99RAheeh7V24Csg/aMW25DT/3CN/h+BaeoM=";
  };
in
stdenv.mkDerivation rec {
  pname = "libgeodesk";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "clarisma";
    repo = "libgeodesk";
    tag = "v${version}";
    hash = "sha256-eX10Gkgsqa+RA+PDk+jdsQly3sUg2p3cFev5qXwhlG4=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "GIT_REPOSITORY https://github.com/boostorg/crc.git" "SOURCE_DIR ${boost_crc}" \
      --replace-fail "GIT_TAG boost-1.86.0" "" \
      --replace-fail "GIT_REPOSITORY https://github.com/catchorg/Catch2.git" "SOURCE_DIR ${catch2}" \
      --replace-fail "GIT_TAG v3.7.1" ""
  '';

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "Fast and storage-efficient spatial database engine for OpenStreetMap data";
    homepage = "https://github.com/clarisma/libgeodesk";
    license = lib.licenses.lgpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
