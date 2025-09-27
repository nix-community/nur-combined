{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  geos,
}:

let
  catch2 = fetchFromGitHub {
    owner = "catchorg";
    repo = "Catch2";
    tag = "v3.7.1";
    hash = "sha256-Zt53Qtry99RAheeh7V24Csg/aMW25DT/3CN/h+BaeoM=";
  };
  gtl = fetchFromGitHub {
    owner = "greg7mdp";
    repo = "gtl";
    tag = "v1.2.0";
    hash = "sha256-kSmHgcaCZDNgNZdGqacrUa7d6iTtDm9BVazXUPnI5Zc=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "libgeodesk";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "clarisma";
    repo = "libgeodesk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OIwYudqTPWIcyh7rpcM1ThPgBfsrTu6REWdTxkC86I0=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "GIT_REPOSITORY https://github.com/catchorg/Catch2.git" "SOURCE_DIR ${catch2}" \
      --replace-fail "GIT_TAG v3.7.1" "" \
      --replace-fail "GIT_REPOSITORY https://github.com/greg7mdp/gtl.git" "SOURCE_DIR ${gtl}" \
      --replace-fail "GIT_TAG v1.2.0" ""
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [ geos ];

  cmakeFlags = [
    (lib.cmakeBool "GEODESK_WITH_GEOS" true)
    (lib.cmakeFeature "GEOS_INCLUDE_PATHS" "${geos}/include")
  ];

  meta = {
    description = "Fast and storage-efficient spatial database engine for OpenStreetMap data";
    homepage = "https://github.com/clarisma/libgeodesk";
    license = lib.licenses.lgpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
