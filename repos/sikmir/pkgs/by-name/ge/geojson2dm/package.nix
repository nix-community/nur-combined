{
  lib,
  stdenv,
  fetchFromSourcehut,
}:

stdenv.mkDerivation {
  pname = "geojson2dm";
  version = "0-unstable-2025-01-29";

  src = fetchFromSourcehut {
    owner = "~sikmir";
    repo = "geojson2dm";
    rev = "5623cccb180399976df1c80776a9520873ed649e";
    hash = "sha256-ZWuAm99JveQ3kDOcScc4zuSSHxf66suIdI2RHAhuRRg=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Convert GeoJSON to format suitable for input to datamaps";
    homepage = "https://git.sikmir.ru/geojson2dm";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
