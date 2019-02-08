{ stdenv, fetchurl, coreutils, bash }:

stdenv.mkDerivation {
  name = "colombia";
  builder = "${bash}/bin/bash"; args = [ ./builder.sh ];
  inherit coreutils;
  src = fetchurl { 
    url = "https://download.geofabrik.de/south-america/colombia-latest.osm.pbf";
    sha256 = "1md7jsfd8pa45z73bz1kszpp01yw6x5ljkjk2hx7wl800any6465";
  };
}

