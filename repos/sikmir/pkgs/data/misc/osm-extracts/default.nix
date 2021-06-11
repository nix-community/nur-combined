{ lib, stdenv, fetchurl, gdal, osmium-tool }:
let
  regions = [
    "RU-ARK"
    "RU-VLG"
    "RU-KGD"
    "RU-KR"
    "RU-KO"
    "RU-LEN"
    "RU-MUR"
    "RU-NEN"
    "RU-NGR"
    "RU-PSK"
    "RU-SPE"
  ];
in
{
  admin-boundaries = stdenv.mkDerivation rec {
    pname = "osm-admin-boundaries";
    version = "210609";

    src = fetchurl {
      url = "https://download.geofabrik.de/russia/northwestern-fed-district-${version}.osm.pbf";
      hash = "sha256-iWuA3Lg3JzaKA4ru8rNH9LjN3dDysEMviXID9O40kao=";
    };

    dontUnpack = true;

    nativeBuildInputs = [ gdal osmium-tool ];

    buildPhase = lib.concatMapStringsSep "\n" (name: ''
      osmium tags-filter -o ${name}-boundary.osm $src r/ISO3166-2=${name}
      osmium extract -p ${name}-boundary.osm $src -s simple -o ${name}.osm
      ogr2ogr -f GeoJSON ${name}-boundary.geojson ${name}-boundary.osm multipolygons
    '') regions;

    installPhase = "install -Dm644 *.geojson *.osm -t $out";

    meta = with lib; {
      description = "Administrative boundaries (NWFD)";
      homepage = "https://wiki.openstreetmap.org/wiki/Tag:boundary%3Dadministrative";
      license = licenses.free;
      maintainers = [ maintainers.sikmir ];
      platforms = platforms.all;
      skip.ci = true;
    };
  };
}
