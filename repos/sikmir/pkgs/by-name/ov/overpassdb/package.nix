{
  lib,
  stdenv,
  fetchurl,
  osmctools,
  osm-3s,
  osm-extracts,
}:

stdenv.mkDerivation {
  pname = "overpassdb";
  inherit (osm-extracts) version;

  dontUnpack = true;

  nativeBuildInputs = [
    osmctools
    osm-3s
  ];

  installPhase = ''
    install -dm755 $out

    osmconvert ${osm-extracts}/RU-LEN.osm.pbf --out-osm | \
      update_database --db-dir=$out --meta
  '';

  meta = {
    description = "Overpass Database";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
}
