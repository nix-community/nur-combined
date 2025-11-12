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
  version = "0.7.62.8";

  src = fetchurl {
    url = "http://dev.overpass-api.de/releases/osm-3s_v${finalAttrs.version}.tar.gz";
    hash = "sha256-G1XyH6oInClHtz7vBCPzqDCU7dWoWtCxBUzz93WEaD0=";
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
