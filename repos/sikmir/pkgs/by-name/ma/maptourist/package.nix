{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "maptourist";
  version = "2025-10-05";

  src = fetchurl {
    url = "https://maptourist.org/osm-garmin/archive/OSM-MapTourist-Caucasus-gmapsupp-RU_${finalAttrs.version}.zip";
    hash = "sha256-VCyJFUYE+ERw983Al5gNEum0Z+pLubH7kNMgyrIJA8I=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = "install -Dm644 *.img -t $out";

  preferLocalBuild = true;

  meta = {
    description = "Ежедневная сборка карт из данных OpenStreetMap для навигационных приборов и приложений Garmin";
    homepage = "https://maptourist.org";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
})
