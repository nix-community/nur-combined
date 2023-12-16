{ lib, stdenvNoCC, fetchurl, unzip }:

stdenvNoCC.mkDerivation rec {
  pname = "maptourist";
  version = "2023-12-14";

  src = fetchurl {
    url = "https://maptourist.org/osm-garmin/archive/OSM-MapTourist-Russia-gmapsupp-RU_${version}.zip";
    hash = "sha256-UCGatAtcqujwh9E8wumiP+73M2BGJdBO5KjFDIwlbyY=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = "install -Dm644 *.img -t $out";

  preferLocalBuild = true;

  meta = with lib; {
    description = "Ежедневная сборка карт из данных OpenStreetMap для навигационных приборов и приложений Garmin";
    homepage = "https://maptourist.org";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
}
