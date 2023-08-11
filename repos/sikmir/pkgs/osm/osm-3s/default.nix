{ lib, stdenv, fetchurl, expat, lz4, zlib }:

stdenv.mkDerivation (finalAttrs: {
  pname = "osm-3s";
  version = "0.7.61.5";

  src = fetchurl {
    url = "http://dev.overpass-api.de/releases/osm-3s_v${finalAttrs.version}.tar.gz";
    hash = "sha256-oV/XLi+ALMHEeSO1+Jo8xkSmx2AspHggBsbY3zDnhSo=";
  };

  buildInputs = [ expat lz4 zlib ];

  configureFlags = [ "--enable-lz4" ];

  meta = with lib; {
    description = "A database engine to query the OpenStreetMap data";
    homepage = "http://overpass-api.de/";
    license = licenses.agpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
