{ lib, stdenv, fetchurl, expat, lz4, zlib }:

stdenv.mkDerivation rec {
  pname = "osm-3s";
  version = "0.7.57.1";

  src = fetchurl {
    url = "http://dev.overpass-api.de/releases/osm-3s_v${version}.tar.gz";
    hash = "sha256-M5W/cCnPr4Ct4KKo+xs+21zEy86x+iBs1LqiQ8JVRhA=";
  };

  buildInputs = [ expat lz4 zlib ];

  configureFlags = [ "--enable-lz4" ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "A database engine to query the OpenStreetMap data";
    homepage = "http://overpass-api.de/";
    license = licenses.agpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
