{ stdenv, fetchurl, coreutils, bash }:

stdenv.mkDerivation {
  name = "jamaica";
  builder = "${bash}/bin/bash"; args = [ ./builder.sh ];
  inherit coreutils;
  src = fetchurl { 
    url = "https://download.geofabrik.de/central-america/jamaica-latest.osm.pbf";
    sha256 = "0f21ghayv0py4dkl0q7pl9f12hcfy8qaiw13a28r8w6i21gzj385";
  };
}

