{
  lib,
  stdenv,
  fetchurl,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "libmdbx";
  version = "0.12.9";

  src = fetchurl {
    url = "https://libmdbx.dqdkfa.ru/release/libmdbx-amalgamated-${version}.tar.xz";
    hash = "sha256-bMxSd7+xPOdE+20hKN4LEcj1jIHB/gYXnOqsXCgSWm4=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DMDBX_BUILD_TIMESTAMP=unknown" ];

  meta = with lib; {
    description = "Extremely fast, compact, powerful, embedded, transactional key-value database";
    homepage = "https://libmdbx.dqdkfa.ru/";
    license = licenses.free; # OpenLDAP Public License
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin;
  };
}
