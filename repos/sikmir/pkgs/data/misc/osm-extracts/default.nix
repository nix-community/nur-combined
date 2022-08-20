{ lib, stdenv, fetchurl, osmium-tool, region ? "RU-LEN" }:

stdenv.mkDerivation rec {
  pname = "osm-extracts-${region}";
  version = "220819";

  src = fetchurl {
    url = "https://download.geofabrik.de/russia/northwestern-fed-district-${version}.osm.pbf";
    hash = "sha256-2LhTMEGeJVLstmOzn1/MJ/Htg2B7Bza4xcxHj68Hr2A=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ osmium-tool ];

  buildPhase = ''
    osmium tags-filter -o ${region}-boundary.osm $src r/ISO3166-2=${region}
    osmium extract -p ${region}-boundary.osm $src --set-bounds -s simple -o ${region}.osm.pbf
    osmium export ${region}-boundary.osm -o ${region}-boundary.geojson
    osmium tags-filter -o ${region}-water.osm ${region}.osm.pbf a/natural=water
    osmium export ${region}-water.osm -o ${region}-water.geojson
  '';

  installPhase = ''
    install -Dm644 *.geojson *.osm *.osm.pbf -t $out
  '';

  meta = with lib; {
    description = "Administrative boundaries (${region})";
    homepage = "https://wiki.openstreetmap.org/wiki/Tag:boundary%3Dadministrative";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
