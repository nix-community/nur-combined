{
  lib,
  stdenv,
  fetchFromGitHub,
  libgrapheme,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "makel";
  version = "0-unstable-2022-01-24";

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
    install -Dm755 makel -t $out/bin
  '';

  meta = {
    description = "Makefile linter";
    homepage = "https://github.com/maandree/makel";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
