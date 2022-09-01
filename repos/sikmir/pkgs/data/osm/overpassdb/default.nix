{ lib, stdenv, fetchurl, osmctools, osm-3s, osm-extracts }:

stdenv.mkDerivation rec {
  pname = "overpassdb";
  inherit (osm-extracts) version;

  dontUnpack = true;

  nativeBuildInputs = [ osmctools osm-3s ];

  installPhase = ''
    install -dm755 $out

    osmconvert ${osm-extracts}/RU-LEN.osm.pbf --out-osm | \
      update_database --db-dir=$out --meta
  '';

  meta = with lib; {
    description = "Overpass Database";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}

