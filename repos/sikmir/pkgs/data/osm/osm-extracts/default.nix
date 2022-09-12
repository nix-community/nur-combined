{ lib, stdenv, fetchurl, osmium-tool }:

stdenv.mkDerivation rec {
  pname = "osm-extracts";
  version = "220911";

  src = fetchurl {
    url = "https://download.geofabrik.de/russia/northwestern-fed-district-${version}.osm.pbf";
    hash = "sha256-wZ7POH5A6wIjHKeaPUB2r9gY1ou+J7sgiKHYaVKbgyY=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ osmium-tool ];

  buildPhase = ''
    runHook preBuild

    for region in RU-{ARK,KO,KR,LEN,MUR,NEN,NGR,PSK,SPE,VLG}; do
      osmium tags-filter -o $region-boundary.osm $src r/ISO3166-2=$region
      osmium extract -p $region-boundary.osm $src --set-bounds -s simple -o $region.osm.pbf
      osmium export $region-boundary.osm -o $region-boundary.geojson
      osmium tags-filter -o $region-water.osm $region.osm.pbf a/natural=water
      osmium export $region-water.osm -o $region-water.geojson
    done

    runHook postBuild
  '';

  installPhase = ''
    install -Dm644 *.geojson *.osm *.osm.pbf -t $out
  '';

  meta = with lib; {
    description = "Administrative boundaries";
    homepage = "https://wiki.openstreetmap.org/wiki/Tag:boundary%3Dadministrative";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
