{
  lib,
  stdenv,
  fetchurl,
  osmium-tool,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "osm-extracts";
  version = "260214";

  src = fetchurl {
    url = "https://download.geofabrik.de/russia/northwestern-fed-district-${finalAttrs.version}.osm.pbf";
    hash = "sha256-xSgrdqB7QTPeTfyq4TnQjFP6HJH/NBAaYVn/nvokUGk=";
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

  meta = {
    description = "Administrative boundaries";
    homepage = "https://wiki.openstreetmap.org/wiki/Tag:boundary%3Dadministrative";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
})
