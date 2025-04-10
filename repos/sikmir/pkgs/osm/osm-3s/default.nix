{
  lib,
  stdenv,
  fetchurl,
  expat,
  lz4,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "osm-3s";
  version = "0.7.62.5";

  src = fetchurl {
    url = "http://dev.overpass-api.de/releases/osm-3s_v${finalAttrs.version}.tar.gz";
    hash = "sha256-xVSV1w9eY6IzrEGrc3LV1OG6XdRt/aUa9IsNrTxWh3I=";
  };

  buildInputs = [
    expat
    lz4
    zlib
  ];

  configureFlags = [ (lib.enableFeature true "lz4") ];

  meta = {
    description = "A database engine to query the OpenStreetMap data";
    homepage = "http://overpass-api.de/";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
