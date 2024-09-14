{
  lib,
  stdenv,
  fetchurl,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libmdbx";
  version = "0.13.1";

  src = fetchurl {
    url = "https://libmdbx.dqdkfa.ru/release/libmdbx-amalgamated-${finalAttrs.version}.tar.xz";
    hash = "sha256-qrtr80uGmbBt5xeo+s+IIKL90bvkrg6QyaK72ziAGB0=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DMDBX_BUILD_TIMESTAMP=unknown" ];

  meta = {
    description = "Extremely fast, compact, powerful, embedded, transactional key-value database";
    homepage = "https://libmdbx.dqdkfa.ru/";
    license = lib.licenses.free; # OpenLDAP Public License
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
