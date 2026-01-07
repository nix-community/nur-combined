{
  lib,
  stdenv,
  fetchurl,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libmdbx";
  version = "0.14.1";

  src = fetchurl {
    url = "https://libmdbx.dqdkfa.ru/release/libmdbx-amalgamated-${finalAttrs.version}.tar.xz";
    hash = "sha256-LtuLWdtbKwIcdjQBD429u/lI7aYJlC3TAFEMbpO9XSU=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ (lib.cmakeFeature "MDBX_BUILD_TIMESTAMP" "unknown") ];

  meta = {
    description = "Extremely fast, compact, powerful, embedded, transactional key-value database";
    homepage = "https://libmdbx.dqdkfa.ru/";
    license = lib.licenses.free; # OpenLDAP Public License
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
