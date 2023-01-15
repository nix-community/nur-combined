{ lib, stdenv, fetchurl, cmake }:

stdenv.mkDerivation rec {
  pname = "libmdbx";
  version = "0.12.3";

  src = fetchurl {
    url = "https://libmdbx.dqdkfa.ru/release/libmdbx-amalgamated-0.12.3.tar.xz";
    hash = "sha256-YwH5Hh+4IbmUJ46g+SDsx+PSuBadg93+ytfxQTVnZZ0=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Extremely fast, compact, powerful, embedded, transactional key-value database";
    homepage = "https://libmdbx.dqdkfa.ru/";
    license = licenses.free; # OpenLDAP Public License
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
