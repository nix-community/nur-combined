{ lib, stdenv, fetchurl, expat, lz4, zlib }:

stdenv.mkDerivation (finalAttrs: {
  pname = "osm-3s";
  version = "0.7.62";

  src = fetchurl {
    url = "http://dev.overpass-api.de/releases/osm-3s_v${finalAttrs.version}.tar.gz";
    hash = "sha256-MimAlodtczWohlkCZJxpwDQWdNmIZzj5RCGT9oU8s+U=";
  };

  buildInputs = [ expat lz4 zlib ];

  configureFlags = [
    (lib.enableFeature true "lz4")
  ];

  meta = with lib; {
    description = "A database engine to query the OpenStreetMap data";
    homepage = "http://overpass-api.de/";
    license = licenses.agpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
