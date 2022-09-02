{ lib, stdenv, fetchFromSourcehut }:

stdenv.mkDerivation rec {
  pname = "gpx2yaml";
  version = "2021-08-19";

  src = fetchFromSourcehut {
    owner = "~sikmir";
    repo = "gpx2yaml";
    rev = "d4a102ab079edf239a095bdd3564be3cac193971";
    hash = "sha256-82RYdC1tUYwYZELTHOC+Llz+KcdLgyipB9wEWekDRww=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "GPX to YAML converter";
    homepage = "https://git.sikmir.ru/gpx2yaml";
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
