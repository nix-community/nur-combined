{
  lib,
  stdenv,
  fetchFromSourcehut,
}:

stdenv.mkDerivation {
  pname = "gpx2yaml";
  version = "0-unstable-2025-01-29";

  src = fetchFromSourcehut {
    owner = "~sikmir";
    repo = "gpx2yaml";
    rev = "c0a28a96635706d8e052fe819c88e265577201b9";
    hash = "sha256-59UVcQh+TsqP/Z55wmtfH002FhScqaflrC5Kyid67tg=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "GPX to YAML converter";
    homepage = "https://git.sikmir.ru/gpx2yaml";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
