{ lib, stdenv, gdal, osmium-tool, sources }:
let
  year = lib.substring 0 2 sources.geofabrik-russia-nwfd.version;
  month = lib.substring 2 2 sources.geofabrik-russia-nwfd.version;
  day = lib.substring 4 2 sources.geofabrik-russia-nwfd.version;

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
  admin-boundaries = stdenv.mkDerivation {
    pname = "osm-admin-boundaries";
    version = "20${year}-${month}-${day}";

    src = sources.geofabrik-russia-nwfd;

    dontUnpack = true;

    nativeBuildInputs = [ gdal osmium-tool ];

    buildPhase = stdenv.lib.concatMapStringsSep "\n"
      (name: ''
        osmium tags-filter -o ${name}-boundary.osm $src r/ISO3166-2=${name}
        ogr2ogr -f GeoJSON ${name}-boundary.geojson ${name}-boundary.osm multipolygons
      '')
      regions;

    installPhase = "install -Dm644 *.geojson -t $out";

    meta = with lib; {
      description = "Administrative boundaries";
      homepage = "https://wiki.openstreetmap.org/wiki/Tag:boundary%3Dadministrative";
      license = licenses.free;
      maintainers = [ maintainers.sikmir ];
      platforms = platforms.all;
      skip.ci = true;
    };
  };
}
