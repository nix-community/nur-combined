{ lib, stdenv, fetchurl, expat, lz4, zlib }:

stdenv.mkDerivation rec {
  pname = "osm-3s";
  version = "0.7.58.5";

  src = fetchurl {
    url = "http://dev.overpass-api.de/releases/osm-3s_v${version}.tar.gz";
    hash = "sha256-Ij2Qf5JLjDUzGMAKBM2KGXo3KpuPNdoOhfaIMTh48cY=";
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
