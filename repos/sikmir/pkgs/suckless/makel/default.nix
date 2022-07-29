{ lib, stdenv, fetchFromGitHub, libgrapheme }:

stdenv.mkDerivation rec {
  pname = "makel";
  version = "2022-01-24";

  src = fetchFromGitHub {
    owner = "maandree";
    repo = "makel";
    rev = "0650e17761ffc45b4fc5d32287514796d6da332d";
    hash = "sha256-ItZaByPpheCuSXdd9ej+ySeX3P6DYgnNNAQlAQeNEDA=";
  };

  buildInputs = [ libgrapheme ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  installPhase = ''
    install -Dm755 makel $out/bin/makel
  '';

  meta = with lib; {
    description = "Makefile linter";
    inherit (src.meta) homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
