{ lib, stdenv, fetchFromSourcehut }:

stdenv.mkDerivation rec {
  pname = "geojson2dm";
  version = "2021-08-25";

  src = fetchFromSourcehut {
    owner = "~sikmir";
    repo = "geojson2dm";
    rev = "64357dfb409f891be1afd5261b918b8bb9987774";
    hash = "sha256-2mn84/YOkUDiYjr9uE27ucOUeUpzj29X0fZXywBAz0I=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Convert GeoJSON to format suitable for input to datamaps";
    homepage = "https://git.sikmir.ru/geojson2dm";
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
