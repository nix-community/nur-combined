{
  lib,
  stdenv,
  fetchurl,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libmdbx";
  version = "0.13.3";

  src = fetchurl {
    url = "https://libmdbx.dqdkfa.ru/release/libmdbx-amalgamated-${finalAttrs.version}.tar.xz";
    hash = "sha256-LkJQXxzrV5RVads8Gl25tSFtj3LafHXCQP+BGW+Omgs=";
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
